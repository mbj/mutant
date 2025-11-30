# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Sorbet Per-Mutation Cache Isolation' do
  let(:project_root) { Pathname.new(Dir.mktmpdir) }
  let(:cache_dir) { project_root.join('tmp', 'sorbet-cache') }
  let(:calculator_file) { project_root.join('calculator.rb') }

  before do
    # Create Calculator class
    calculator_file.write(<<~RUBY)
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
    FileUtils.rm_rf(project_root)
  end

  describe 'Sequential mutations within same worker' do
    it 'each mutation gets isolated cache - mutation N+1 does not see mutation N changes' do
      # Pre-warm parent cache with clean Calculator
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Mutation 0: Change Calculator to return String instead of Integer
      checker_mutation_0 = Mutant::Sorbet::TypeChecker.for_mutation(
        project_root: project_root,
        parent_cache_dir: cache_dir,
        mutation_index: 0
      )

      # Open and mutate for mutation 0
      checker_mutation_0.lsp_client.open_document(
        file_path: calculator_file,
        content: calculator_file.read
      )
      checker_mutation_0.lsp_client.wait_for_diagnostics(timeout: 5)
      baseline_0 = checker_mutation_0.lsp_client.diagnostics_for(calculator_file)

      mutated_source_0 = calculator_file.read.gsub('x + y', '"string"')
      checker_mutation_0.lsp_client.change_document(
        file_path: calculator_file,
        content: mutated_source_0,
        version: 2
      )
      checker_mutation_0.lsp_client.wait_for_diagnostics(timeout: 5)
      mutated_0_diagnostics = checker_mutation_0.lsp_client.diagnostics_for(calculator_file)

      # Mutation 0 should detect type error
      mutation_0_errors = mutated_0_diagnostics - baseline_0
      expect(mutation_0_errors).not_to be_empty

      # Close mutation 0's LSP client and clean up its cache
      checker_mutation_0.cleanup

      # CRITICAL TEST: Mutation 1 with DIFFERENT mutation
      # If cache isolation works, mutation 1 will NOT see mutation 0's changes
      checker_mutation_1 = Mutant::Sorbet::TypeChecker.for_mutation(
        project_root: project_root,
        parent_cache_dir: cache_dir,
        mutation_index: 1
      )

      # Open ORIGINAL Calculator (not mutation 0's version)
      checker_mutation_1.lsp_client.open_document(
        file_path: calculator_file,
        content: calculator_file.read  # Original, clean content
      )
      checker_mutation_1.lsp_client.wait_for_diagnostics(timeout: 5)
      mutation_1_baseline = checker_mutation_1.lsp_client.diagnostics_for(calculator_file)

      # Mutation 1 should see CLEAN baseline
      # If mutation 0 polluted the cache, we'd see errors here
      expect(mutation_1_baseline).to be_empty

      # Apply a DIFFERENT mutation for mutation 1
      mutated_source_1 = calculator_file.read.gsub('x + y', 'x - y')  # Different mutation
      checker_mutation_1.lsp_client.change_document(
        file_path: calculator_file,
        content: mutated_source_1,
        version: 2
      )
      checker_mutation_1.lsp_client.wait_for_diagnostics(timeout: 5)
      mutated_1_diagnostics = checker_mutation_1.lsp_client.diagnostics_for(calculator_file)

      # Mutation 1 should have NO errors (x - y still returns Integer)
      # This proves mutation 1 is NOT seeing mutation 0's String return type
      mutation_1_errors = mutated_1_diagnostics - mutation_1_baseline
      expect(mutation_1_errors).to be_empty

      # Clean up
      checker_mutation_1.cleanup

      # Verify mutation 0's cache was cleaned up
      mutation_0_cache = cache_dir.to_s + "-worker-#{Process.pid}-mutation-0"
      expect(File.exist?(mutation_0_cache)).to be false

      # Verify mutation 1's cache was cleaned up
      mutation_1_cache = cache_dir.to_s + "-worker-#{Process.pid}-mutation-1"
      expect(File.exist?(mutation_1_cache)).to be false

      # Verify parent cache still exists and is pristine
      expect(cache_dir).to exist
      expect(cache_dir.join('data.mdb')).to exist
    end
  end

  describe 'Three sequential mutations' do
    it 'mutations remain isolated despite sequential execution in same process' do
      # Pre-warm parent cache
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      results = []

      # Run 3 mutations sequentially (like a worker would)
      3.times do |mutation_index|
        checker = Mutant::Sorbet::TypeChecker.for_mutation(
          project_root: project_root,
          parent_cache_dir: cache_dir,
          mutation_index: mutation_index
        )

        # Each mutation opens original file
        checker.lsp_client.open_document(
          file_path: calculator_file,
          content: calculator_file.read
        )
        checker.lsp_client.wait_for_diagnostics(timeout: 5)
        baseline = checker.lsp_client.diagnostics_for(calculator_file)

        # All mutations should see clean baseline
        results << { mutation_index: mutation_index, baseline_clean: baseline.empty? }

        checker.cleanup
      end

      # All three mutations saw clean baseline
      # None saw pollution from previous mutations
      expect(results).to all(include(baseline_clean: true))
      expect(results.map { |r| r[:mutation_index] }).to eq([0, 1, 2])
    end
  end
end
