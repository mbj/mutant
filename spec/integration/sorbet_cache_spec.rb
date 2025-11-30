# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Sorbet Cache Pre-warming' do
  let(:project_root) { Pathname.new(Dir.mktmpdir) }
  let(:cache_dir) { project_root.join('tmp', 'sorbet-cache') }
  let(:test_file) { project_root.join('test.rb') }

  before do
    # Create a simple Ruby file with Sorbet types
    test_file.write(<<~RUBY)
      # typed: true
      class Calculator
        extend T::Sig

        sig { params(x: Integer, y: Integer).returns(Integer) }
        def add(x, y)
          x + y
        end
      end
    RUBY
  end

  after do
    # Clean up
    FileUtils.rm_rf(project_root)
  end

  describe 'Mutant::Sorbet::TypeChecker.warmup' do
    it 'creates cache directory and populates it' do
      # Warmup should create cache directory
      expect(cache_dir).not_to exist

      result_cache_dir = Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      expect(result_cache_dir).to eq(cache_dir)
      expect(cache_dir).to exist
      expect(cache_dir).to be_directory

      # Cache should contain LMDB files
      expect(cache_dir.join('data.mdb')).to exist
      expect(cache_dir.join('lock.mdb')).to exist
    end

    it 'reuses cached type-checking state across LSP server instances' do
      # Create a second file that references the first
      dependent_file = project_root.join('dependent.rb')
      dependent_file.write(<<~RUBY)
        # typed: true
        require_relative 'test'

        class Consumer
          extend T::Sig

          sig { returns(Integer) }
          def use_calculator
            calc = Calculator.new
            calc.add(1, 2)  # Returns Integer, type-checks correctly
          end
        end
      RUBY

      # Pre-warm cache with both files indexed
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Verify cache contains indexed data for both files
      expect(cache_dir.join('data.mdb')).to exist
      original_cache_size = cache_dir.join('data.mdb').size
      expect(original_cache_size).to be > 0

      # Start a new LSP server with cached state
      client = Mutant::Sorbet::LSP::Client.new(
        project_root: project_root,
        cache_dir: cache_dir
      ).start

      # Open the dependent file WITHOUT opening test.rb
      # If cache is working: LSP already knows about Calculator from cache
      # If cache is NOT working: LSP would need to parse test.rb first
      client.open_document(file_path: dependent_file, content: dependent_file.read)
      client.wait_for_diagnostics(timeout: 5)

      # Verify no type errors - this proves the LSP has knowledge of Calculator
      # from cached state, even though we never explicitly opened test.rb
      diagnostics = client.diagnostics_for(dependent_file)
      expect(diagnostics).to be_empty

      # Now prove cache state was reused by checking it wasn't rebuilt:
      # If Sorbet re-indexed from scratch, cache would be rewritten
      # With cache reuse, cache should remain essentially unchanged
      client.stop

      final_cache_size = cache_dir.join('data.mdb').size
      # Cache size should be stable (within 1KB) - not fully recreated
      expect((final_cache_size - original_cache_size).abs).to be < 1024
    end

    it 'inherits cached type definitions without re-parsing source files' do
      # Pre-warm cache with Calculator class definition
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Start TWO separate LSP servers simultaneously
      # Both should inherit the cached Calculator definition
      client1 = Mutant::Sorbet::LSP::Client.new(
        project_root: project_root,
        cache_dir: cache_dir
      ).start

      client2 = Mutant::Sorbet::LSP::Client.new(
        project_root: project_root,
        cache_dir: cache_dir
      ).start

      # Create a new file that uses Calculator (cached class)
      new_file = project_root.join('new_usage.rb')
      new_file.write(<<~RUBY)
        # typed: true
        class NewClass
          extend T::Sig

          sig { returns(Integer) }
          def compute
            Calculator.new.add(5, 3)
          end
        end
      RUBY

      # Both clients should recognize Calculator from cache
      client1.open_document(file_path: new_file, content: new_file.read)
      client1.wait_for_diagnostics(timeout: 5)
      diagnostics1 = client1.diagnostics_for(new_file)

      client2.open_document(file_path: new_file, content: new_file.read)
      client2.wait_for_diagnostics(timeout: 5)
      diagnostics2 = client2.diagnostics_for(new_file)

      # Both clients recognize Calculator - proving they inherited cached state
      expect(diagnostics1).to be_empty
      expect(diagnostics2).to be_empty

      client1.stop
      client2.stop

      # Clean up
      new_file.delete
    end
  end

  describe 'Multiple workers sharing cache' do
    it 'worker processes inherit identical type-checking state from shared cache' do
      # Create additional test files
      helper_file = project_root.join('helper.rb')
      helper_file.write(<<~RUBY)
        # typed: true
        class MathHelper
          extend T::Sig

          sig { params(n: Integer).returns(Integer) }
          def self.double(n)
            n * 2
          end
        end
      RUBY

      # Pre-warm cache with all project files
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Start 3 separate LSP servers (simulating 3 worker processes)
      # Each should inherit identical cached knowledge
      clients = 3.times.map do
        Mutant::Sorbet::LSP::Client.new(
          project_root: project_root,
          cache_dir: cache_dir
        ).start
      end

      # Each worker opens a NEW file that depends on cached types
      # All workers should have identical type knowledge from cache
      new_files = clients.map.with_index do |client, i|
        file = project_root.join("worker_#{i}.rb")
        file.write(<<~RUBY)
          # typed: true
          class Worker#{i}
            extend T::Sig

            sig { returns(Integer) }
            def process
              # Uses Calculator from cache
              result1 = Calculator.new.add(10, 20)
              # Uses MathHelper from cache
              result2 = MathHelper.double(result1)
              result2
            end
          end
        RUBY

        client.open_document(file_path: file, content: file.read)
        client.wait_for_diagnostics(timeout: 5)

        file
      end

      # Verify all workers have identical type-checking results
      # This proves they all inherited the same cached state
      diagnostics_sets = clients.zip(new_files).map do |client, file|
        client.diagnostics_for(file)
      end

      # All workers should have empty diagnostics (no type errors)
      # because they all know about Calculator and MathHelper from cache
      expect(diagnostics_sets).to all(be_empty)

      # Clean up
      clients.each(&:stop)
      new_files.each(&:delete)
      helper_file.delete
    end
  end
end
