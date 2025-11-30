# frozen_string_literal: true

module Mutant
  # Mutation testing execution environment
  # rubocop:disable Metrics/ClassLength
  class Env
    include Adamantium, Anima.new(
      :config,
      :hooks,
      :integration,
      :matchable_scopes,
      :mutations,
      :parser,
      :selector,
      :subjects,
      :world
    )

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'

    # Construct minimal empty env
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Env]
    #
    # rubocop:disable Metrics/MethodLength
    def self.empty(world, config)
      new(
        config:,
        hooks:            Hooks.empty,
        integration:      Integration::Null.new(
          arguments:         EMPTY_ARRAY,
          expression_parser: config.expression_parser,
          world:
        ),
        matchable_scopes: EMPTY_ARRAY,
        mutations:        EMPTY_ARRAY,
        parser:           Parser.new,
        selector:         Selector::Null.new,
        subjects:         EMPTY_ARRAY,
        world:
      )
    end
    # rubocop:enable Metrics/MethodLength

    # Cover mutation with specific index
    #
    # @param [Integer] mutation_index
    #
    # @return [Result::MutationIndex]
    def cover_index(mutation_index)
      mutation = mutations.fetch(mutation_index)

      start = timer.now

      tests = selections.fetch(mutation.subject)

      Result::MutationIndex.new(
        isolation_result: run_mutation_tests(mutation, mutation_index, tests),
        mutation_index:,
        runtime:          timer.now - start
      )
    end

    def run_test_index(test_index)
      integration.call([integration.all_tests.fetch(test_index)])
    end

    def emit_mutation_worker_process_start(index:)
      hooks.run(:mutation_worker_process_start, index:)
    end

    def emit_test_worker_process_start(index:)
      hooks.run(:test_worker_process_start, index:)
    end

    # The test selections
    #
    # @return Hash{Mutation => Enumerable<Test>}
    def selections
      subjects.to_h do |subject|
        [subject, selector.call(subject)]
      end
    end
    memoize :selections

    # Emit warning
    #
    # @param [String] warning
    #
    # @return [self]
    def warn(message)
      config.reporter.warn(message)
      self
    end

    # Selected tests
    #
    # @return [Set<Test>]
    def selected_tests
      selections.values.flatten.to_set
    end
    memoize :selected_tests

    # Amount of mutations
    #
    # @return [Integer]
    def amount_mutations
      mutations.length
    end
    memoize :amount_mutations

    # Amount of all tests the integration provides
    #
    # @return [Integer]
    def amount_all_tests
      integration.all_tests.length
    end
    memoize :amount_all_tests

    # Amount of tests available for mutation testing
    #
    # @return [Integer]
    def amount_available_tests
      integration.available_tests.length
    end
    memoize :amount_available_tests

    # Amount of selected subjects
    #
    # @return [Integer]
    def amount_subjects
      subjects.length
    end
    memoize :amount_subjects

    # Amount of selected tests
    #
    # @return [Integer]
    def amount_selected_tests
      selected_tests.length
    end
    memoize :amount_selected_tests

    # Ratio between selected tests and subjects
    #
    # @return [Rational]
    def test_subject_ratio
      return Rational(0) if amount_subjects.zero?

      Rational(amount_selected_tests, amount_subjects)
    end
    memoize :test_subject_ratio

    # Record segment
    #
    # @param [Symbol] name
    #
    # @return [self]
    def record(name, &)
      world.record(name, &)
    end

  # Pre-warm Sorbet cache before forking workers
  # Called once in main process to populate shared cache
  def warmup_sorbet
    return unless config.sorbet.enabled?

    project_root = config.includes.first || world.pathname.pwd
    cache_dir = config.sorbet.cache_dir&.then { |dir| world.pathname.new(dir) }

    Sorbet::TypeChecker.warmup(project_root:, cache_dir:)
  end

  private

    def run_mutation_tests(mutation, mutation_index, tests)
      config.isolation.call(config.mutation.timeout) do
        hooks.run(:mutation_insert_pre, mutation:)
        result = mutation.insert(world.kernel)
        hooks.run(:mutation_insert_post, mutation:)

        result.either(
          ->(_) { Result::Test::VoidValue.instance },
          ->(_) {
            # Check types AFTER mutation is inserted if Sorbet is enabled
            # Each mutation gets a FRESH type checker with isolated cache
            # to prevent cache pollution across mutations
            if config.sorbet.enabled
              type_result = type_check_mutation(mutation, mutation_index)
              if type_result.killed_by_types
                # Mutation killed by types, return early without running tests
                return Result::Test::VoidValue.instance.with(
                  passed: false,
                  output: "Killed by Sorbet type checker:\n#{type_result.type_errors.map { |e| e[:message] }.join("\n")}"
                )
              end
            end

            integration.call(tests)
          }
        )
      end
    end

    # Type check a single mutation with isolated cache
    # Each mutation gets its own cache copy to prevent pollution
    def type_check_mutation(mutation, mutation_index)
      project_root = config.includes.first || world.pathname.pwd
      cache_dir = config.sorbet.cache_dir&.then { |dir| world.pathname.new(dir) }

      # Create type checker for THIS mutation only (fresh LSP + isolated cache)
      checker = Sorbet::TypeChecker.for_mutation(
        project_root:,
        parent_cache_dir: cache_dir,
        mutation_index:
      )

      checker.check_mutation(mutation:)
    rescue StandardError
      # If type checking fails for any reason (LSP crash, timeout, etc.),
      # treat it as if the mutation passes type checking
      # This prevents infrastructure failures from killing the mutation run
      Sorbet::TypeChecker::Result.success(mutation:)
    ensure
      # Always clean up the LSP client and cache, even if there was an error
      checker&.cleanup
    end

    def timer
      world.timer
    end
  end # Env
  # rubocop:enable Metrics/ClassLength
end # Mutant
