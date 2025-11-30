# frozen_string_literal: true

module Mutant
  module Sorbet
    # Type checker for mutations using Sorbet LSP
    class TypeChecker
      include Anima.new(:project_root, :lsp_client, :cache_dir)

      # Registry of parent cache directory (set during warmup)
      @parent_cache_dir = nil

      class << self
        attr_accessor :parent_cache_dir

        # Create type checker for a SINGLE mutation with isolated cache
        # This ensures mutations don't pollute each other's type-checking state
        def for_mutation(project_root:, parent_cache_dir:, mutation_index:)
          parent_cache = parent_cache_dir || @parent_cache_dir || default_cache_dir(project_root)

          # Create isolated cache for THIS mutation only
          mutation_cache = create_mutation_cache(parent_cache, mutation_index)

          new(
            project_root:,
            lsp_client: LSP::Client.new(project_root:, cache_dir: mutation_cache).start,
            cache_dir: mutation_cache
          )
        end

        # Legacy method for tests - kept for compatibility
        def for_process(project_root:, cache_dir: nil)
          parent_cache = cache_dir || @parent_cache_dir || default_cache_dir(project_root)
          worker_cache = create_worker_cache(parent_cache, Process.pid)

          new(
            project_root:,
            lsp_client: LSP::Client.new(project_root:, cache_dir: worker_cache).start,
            cache_dir: worker_cache
          )
        end

        # Determine default cache directory
        def default_cache_dir(project_root)
          Pathname.new(project_root).join('tmp', 'sorbet-cache')
        end

        # Pre-warm Sorbet cache before forking workers
        # This starts a temporary LSP server, lets it index the project,
        # then stops it. Worker processes will copy this pristine cache.
        def warmup(project_root:, cache_dir: nil)
          cache_dir ||= @parent_cache_dir || default_cache_dir(project_root)
          @parent_cache_dir = cache_dir  # Store for worker processes to copy from

          # Ensure parent cache directory exists
          cache_dir.mkpath unless cache_dir.exist?

          # Start temporary LSP server to populate parent cache
          client = LSP::Client.new(project_root:, cache_dir:).start

          # Give it time to index the project (wait for initial diagnostics to settle)
          client.wait_for_diagnostics(timeout: 30, settle_time: 2.0)

          # Stop the temporary server
          client.stop

          cache_dir
        end

        # Create isolated cache for a single mutation
        # Each mutation gets its own cache copy to prevent pollution
        def create_mutation_cache(parent_cache_dir, mutation_index)
          mutation_cache_dir = Pathname.new(
            "#{parent_cache_dir}-worker-#{Process.pid}-mutation-#{mutation_index}"
          )

          copy_parent_cache(parent_cache_dir, mutation_cache_dir)
          mutation_cache_dir
        end

        # Create isolated per-worker cache by copying parent cache
        # Used by tests and legacy code
        def create_worker_cache(parent_cache_dir, worker_id)
          worker_cache_dir = Pathname.new("#{parent_cache_dir}-worker-#{worker_id}")
          copy_parent_cache(parent_cache_dir, worker_cache_dir)
          worker_cache_dir
        end

        # Copy parent cache to a new directory for isolation
        def copy_parent_cache(source_dir, dest_dir)
          # If parent cache exists and is populated, copy it
          if source_dir.exist? && source_dir.join('data.mdb').exist?
            # Remove stale cache if it exists
            FileUtils.rm_rf(dest_dir) if dest_dir.exist?

            # Create fresh cache directory
            dest_dir.mkpath

            # Copy parent cache files (snapshot inheritance)
            FileUtils.cp(
              source_dir.join('data.mdb'),
              dest_dir.join('data.mdb')
            )

            # Note: lock.mdb is process-specific, don't copy it
            # Sorbet will create its own lock file
          else
            # No parent cache to inherit, create empty cache
            dest_dir.mkpath
          end
        end

        # Legacy cleanup for tests
        def clear_process
          # Not needed for per-mutation model, but kept for test compatibility
        end
      end

      # Cleanup this mutation's isolated cache and LSP server
      def cleanup
        lsp_client&.stop
        FileUtils.rm_rf(cache_dir) if cache_dir.exist?
      end

      # Result of type checking a mutation
      class Result
        include Adamantium, Anima.new(:mutation, :type_errors, :killed_by_types)

        def self.success(mutation:)
          new(mutation: mutation, type_errors: [], killed_by_types: false)
        end

        def self.killed(mutation:, type_errors:)
          new(mutation: mutation, type_errors: type_errors, killed_by_types: true)
        end
      end

      # Check if a mutation introduces new type errors
      # Each check is completely isolated - opens document, checks, closes
      def check_mutation(mutation:)
        file_path = mutation.subject.source_path
        original_source = file_path.read

        # Open original document and get baseline
        lsp_client.open_document(file_path:, content: original_source)
        lsp_client.wait_for_diagnostics(timeout: 5)
        baseline = lsp_client.diagnostics_for(file_path)

        # Construct full mutated file content
        mutated_source = construct_mutated_file(original_source, mutation)

        # Apply mutation
        lsp_client.change_document(
          file_path:,
          content: mutated_source,
          version: 2
        )

        # Wait for type checking to complete
        unless lsp_client.wait_for_diagnostics(timeout: 5)
          # Timeout - can't determine, assume not killed
          lsp_client.close_document(file_path:)
          return Result.success(mutation:)
        end

        # Get diagnostics after mutation
        mutated_diagnostics = lsp_client.diagnostics_for(file_path)

        # Close document to clean up state
        lsp_client.close_document(file_path:)

        # Check if new errors appeared
        new_errors = mutated_diagnostics - baseline

        if new_errors.empty?
          Result.success(mutation:)
        else
          Result.killed(mutation:, type_errors: new_errors)
        end
      end

    private

      # Construct full file content with mutation applied
      # For simple files with header comments + class/module, this prepends headers to monkeypatch
      def construct_mutated_file(original_source, mutation)
        # Extract header comments (lines starting with #)
        header_lines = original_source.lines.take_while { |line| line.strip.start_with?('#') || line.strip.empty? }
        header = header_lines.join

        # Get the monkeypatch (mutated class/module)
        monkeypatch = mutation.monkeypatch

        # Combine header + monkeypatch
        if header.empty?
          monkeypatch
        else
          "#{header}\n#{monkeypatch}"
        end
      end
    end
  end
end
