# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Sorbet Cache Copy-on-Write Isolation' do
  let(:project_root) { Pathname.new(Dir.mktmpdir) }
  let(:cache_dir) { project_root.join('tmp', 'sorbet-cache') }
  let(:test_file) { project_root.join('calculator.rb') }

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

  describe 'Worker cache isolation' do
    it 'workers inherit parent cache but mutations do not pollute parent or siblings' do
      # Pre-warm parent cache with clean Calculator class
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Verify parent cache exists and is populated
      expect(cache_dir.join('data.mdb')).to exist

      # Simulate 3 worker processes by forking
      worker_pids = []
      read_pipes = []

      3.times do |worker_id|
        read_pipe, write_pipe = IO.pipe

        pid = fork do
          read_pipe.close

          # Worker creates its own type checker (gets isolated cache copy)
          checker = Mutant::Sorbet::TypeChecker.for_process(
            project_root: project_root,
            cache_dir: cache_dir
          )

          # Verify worker has its own cache directory
          worker_cache_dir = cache_dir.to_s + "-worker-#{Process.pid}"
          worker_cache_exists = File.exist?(worker_cache_dir)

          # Open original file and get baseline
          checker.lsp_client.open_document(file_path: test_file, content: test_file.read)
          checker.lsp_client.wait_for_diagnostics(timeout: 5)
          baseline = checker.lsp_client.diagnostics_for(test_file)

          # Apply a mutation (this should only affect worker's cache)
          # Change return type from Integer to String - creates type error
          mutated_source = test_file.read.gsub(
            'x + y',
            '"mutation"'
          )

          checker.lsp_client.change_document(
            file_path: test_file,
            content: mutated_source,
            version: 2
          )
          checker.lsp_client.wait_for_diagnostics(timeout: 5)
          mutated_diagnostics = checker.lsp_client.diagnostics_for(test_file)

          # Worker should detect the type error (String returned instead of Integer)
          new_errors = mutated_diagnostics - baseline
          has_errors = !new_errors.empty?

          # Record worker cache modification
          worker_cache_path = Pathname.new(worker_cache_dir)
          worker_cache_data_size = worker_cache_path.join('data.mdb').exist? ?
            worker_cache_path.join('data.mdb').size : 0

          # Send results back to parent
          write_pipe.write(Marshal.dump({
            worker_id: worker_id,
            worker_cache_exists: worker_cache_exists,
            worker_cache_data_size: worker_cache_data_size,
            baseline_error_count: baseline.size,
            mutated_error_count: mutated_diagnostics.size,
            has_new_errors: has_errors
          }))
          write_pipe.close

          Mutant::Sorbet::TypeChecker.clear_process
        end

        write_pipe.close
        worker_pids << pid
        read_pipes << read_pipe
      end

      # Collect results from all workers
      results = read_pipes.map do |pipe|
        data = pipe.read
        pipe.close
        Marshal.load(data)
      end

      # Wait for all workers to finish
      worker_pids.each { |pid| Process.wait(pid) }

      # Verify all workers operated with isolated caches
      results.each do |result|
        # Each worker had its own cache directory
        expect(result[:worker_cache_exists]).to be true

        # Each worker's cache was populated (inherited from parent)
        expect(result[:worker_cache_data_size]).to be > 0

        # Baseline should be clean (no errors in original file)
        expect(result[:baseline_error_count]).to eq(0)
      end

      # All workers should have operated independently
      expect(results.map { |r| r[:worker_id] }.sort).to eq([0, 1, 2])

      # CRITICAL SEMANTIC TEST: Verify parent cache was NOT polluted by worker mutations
      # Start a NEW type checker in parent process using parent cache
      parent_checker = Mutant::Sorbet::TypeChecker.for_process(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Open the original Calculator file (the one workers mutated in their caches)
      parent_checker.lsp_client.open_document(
        file_path: test_file,
        content: test_file.read
      )
      parent_checker.lsp_client.wait_for_diagnostics(timeout: 5)
      parent_diagnostics = parent_checker.lsp_client.diagnostics_for(test_file)

      # PROOF OF ISOLATION: Parent sees ZERO type errors in the original file
      # If workers had polluted the parent cache, we'd see their mutations here
      expect(parent_diagnostics).to be_empty

      # Now apply the SAME mutation the workers did, in parent's cache
      mutated_source = test_file.read.gsub('x + y', '"mutation"')
      parent_checker.lsp_client.change_document(
        file_path: test_file,
        content: mutated_source,
        version: 2
      )
      parent_checker.lsp_client.wait_for_diagnostics(timeout: 5)
      parent_mutated_diagnostics = parent_checker.lsp_client.diagnostics_for(test_file)

      # Parent SHOULD see type errors when it applies the mutation itself
      # This proves the parent cache is working correctly, and the reason
      # it didn't see errors before was isolation, not a broken type checker
      expect(parent_mutated_diagnostics).not_to be_empty
      error_messages = parent_mutated_diagnostics.map { |d| d[:message] }.join(' ')
      expect(error_messages).to match(/String.*Integer|Expected.*Integer/)

      Mutant::Sorbet::TypeChecker.clear_process
    end

    it 'multiple mutations in different workers remain isolated from parent' do
      # Pre-warm parent cache
      Mutant::Sorbet::TypeChecker.warmup(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Fork worker that applies type-breaking mutation to Calculator
      pid = fork do
        checker = Mutant::Sorbet::TypeChecker.for_process(
          project_root: project_root,
          cache_dir: cache_dir
        )

        # Get baseline (clean)
        checker.lsp_client.open_document(file_path: test_file, content: test_file.read)
        checker.lsp_client.wait_for_diagnostics(timeout: 5)
        baseline = checker.lsp_client.diagnostics_for(test_file)

        # Mutate Calculator to return String instead of Integer
        mutated_calculator = test_file.read.gsub('x + y', '"broken"')
        checker.lsp_client.change_document(
          file_path: test_file,
          content: mutated_calculator,
          version: 2
        )
        checker.lsp_client.wait_for_diagnostics(timeout: 5)
        mutated_diagnostics = checker.lsp_client.diagnostics_for(test_file)

        # Worker sees the type error (sig says Integer, returns String)
        new_errors = mutated_diagnostics - baseline
        has_error = !new_errors.empty?

        # Signal result to parent
        File.write(project_root.join('worker_result.txt'), has_error ? 'error' : 'clean')

        Mutant::Sorbet::TypeChecker.clear_process
      end

      Process.wait(pid)
      worker_saw_error = File.read(project_root.join('worker_result.txt')) == 'error'

      # PROOF OF ISOLATION: Parent checks the SAME file
      # Parent cache was NOT polluted by worker's mutation
      parent_checker = Mutant::Sorbet::TypeChecker.for_process(
        project_root: project_root,
        cache_dir: cache_dir
      )

      # Open ORIGINAL Calculator (not mutated version)
      parent_checker.lsp_client.open_document(
        file_path: test_file,
        content: test_file.read
      )
      parent_checker.lsp_client.wait_for_diagnostics(timeout: 5)
      parent_diagnostics = parent_checker.lsp_client.diagnostics_for(test_file)

      # Worker saw type error in its isolated cache
      expect(worker_saw_error).to be true

      # Parent sees CLEAN state - no errors in original Calculator
      # If worker had polluted parent cache, parent would see mutation's type error
      expect(parent_diagnostics).to be_empty

      # Double-check: Apply same mutation in parent, should NOW see error
      mutated_calculator = test_file.read.gsub('x + y', '"broken"')
      parent_checker.lsp_client.change_document(
        file_path: test_file,
        content: mutated_calculator,
        version: 2
      )
      parent_checker.lsp_client.wait_for_diagnostics(timeout: 5)
      parent_mutated_diagnostics = parent_checker.lsp_client.diagnostics_for(test_file)

      # NOW parent sees the error (proving type checker works, isolation was real)
      expect(parent_mutated_diagnostics).not_to be_empty

      Mutant::Sorbet::TypeChecker.clear_process
    end
  end
end
