# frozen_string_literal: true

require 'anima'
require 'morpher'
require 'mutant'
require 'parallel'

# @api private
module MutantSpec
  ROOT = Pathname.new(__FILE__).parent.parent.parent

  # Namespace module for corpus testing
  #
  # rubocop:disable MethodLength
  module Corpus
    TMP                 = ROOT.join('tmp').freeze
    EXCLUDE_GLOB_FORMAT = '{%s}'

    # Not in the docs. Number from chatting with their support.
    # 2 processors allocated per container, 4 processes works well.
    CIRCLE_CI_CONTAINER_PROCESSES = 4

    private_constant(*constants(false))

    # Project under corpus test
    # rubocop:disable ClassLength
    class Project
      MUTEX = Mutex.new

      MUTATION_GENERATION_MESSAGE = 'Total Mutations/Time/Parse-Errors: %s/%0.2fs - %0.2f/s'
      START_MESSAGE               = 'Starting - %s'
      FINISH_MESSAGE              = 'Mutations - %4i - %s'

      DEFAULT_MUTATION_COUNT = 0

      include Adamantium, Anima.new(
        :expected_errors,
        :mutation_coverage,
        :mutation_generation,
        :integration,
        :name,
        :namespace,
        :repo_uri,
        :repo_ref,
        :ruby_glob_pattern,
        :exclude
      )

      # Verify mutation coverage
      #
      # @return [self]
      #   if successful
      #
      # @raise [Exception]
      def verify_mutation_coverage
        checkout
        Dir.chdir(repo_path) do
          Bundler.with_clean_env do
            install_mutant
            system(
              %W[
                bundle exec mutant
                --use #{integration}
                --include lib
                --require #{name}
                #{namespace}*
              ]
            )
          end
        end
      end

      # Verify mutation generation
      #
      # @return [self]
      #   if successful
      #
      # @raise [Exception]
      #   otherwise
      def verify_mutation_generation
        checkout
        start = Mutant::Timer.now

        options = {
          finish:       method(:finish),
          start:        method(:start),
          in_processes: parallel_processes
        }

        total = Parallel.map(effective_ruby_paths, options, &method(:check_generation))
          .inject(DEFAULT_MUTATION_COUNT, :+)

        took = Mutant::Timer.now - start
        puts MUTATION_GENERATION_MESSAGE % [total, took, total / took]
        self
      end

      # Checkout repository
      #
      # @return [self]
      def checkout
        return self if noinstall?
        TMP.mkdir unless TMP.directory?

        if repo_path.exist?
          Dir.chdir(repo_path) do
            system(%w[git fetch origin])
            system(%w[git reset --hard])
            system(%w[git clean -f -d -x])
          end
        else
          system(%W[git clone #{repo_uri} #{repo_path}])
        end

        Dir.chdir(repo_path) do
          system(%W[git checkout #{repo_ref}])
          system(%w[git reset --hard])
          system(%w[git clean -f -d -x])
        end

        self
      end
      memoize :checkout

    private

      # Count mutations and check error results against whitelist
      #
      # @param path [Pathname] path responsible for exception
      #
      # @return [Integer] mutations generated
      def check_generation(path)
        relative_path = path.relative_path_from(repo_path)

        node = Parser::CurrentRuby.parse(path.read)
        fail "Cannot parse: #{path}" unless node

        mutations = Mutant::Mutator.mutate(node)

        mutations.each do |mutation|
          check_generation_invariants(node, mutation)
        end

        expected_errors.assert_success(relative_path)

        mutations.length
      rescue Exception => exception # rubocop:disable Lint/RescueException
        expected_errors.assert_error(relative_path, exception)

        DEFAULT_MUTATION_COUNT
      end

      # Check generation invariants
      #
      # @param [Parser::AST::Node] original
      # @param [Parser::AST::Node] mutation
      #
      # @return [undefined]
      #
      # @raise [Exception]
      def check_generation_invariants(original, mutation)
        return unless ENV['MUTANT_CORPUS_EXPENSIVE']

        original_source = Unparser.unparse(original)
        mutation_source = Unparser.unparse(mutation)

        Mutant::Diff.build(original_source, mutation_source) and return

        fail Mutant::Reporter::CLI::NO_DIFF_MESSAGE % [
          original_source,
          original.inspect,
          mutation_source,
          mutation.inspect
        ]
      end

      # Install mutant
      #
      # @return [undefined]
      def install_mutant
        return if noinstall?
        relative = ROOT.relative_path_from(repo_path)
        repo_path.join('Gemfile').open('a') do |file|
          file << "gem 'mutant', path: '#{relative}'\n"
          file << "gem 'mutant-rspec', path: '#{relative}'\n"
          file << "gem 'mutant-minitest', path: '#{relative}'\n"
          file << "eval_gemfile File.expand_path('#{relative.join('Gemfile.shared')}')\n"
        end
        lockfile = repo_path.join('Gemfile.lock')
        lockfile.delete if lockfile.exist?
        system(%w[bundle])
      end

      # The effective ruby file paths
      #
      # @return [Array<Pathname>]
      def effective_ruby_paths
        Pathname
          .glob(repo_path.join(ruby_glob_pattern))
          .sort_by(&:size)
          .reverse
          .reject { |path| exclude.include?(path.relative_path_from(repo_path).to_s) }
      end

      # Number of parallel processes to use
      #
      # @return [Integer]
      def parallel_processes
        if ENV.key?('CI')
          CIRCLE_CI_CONTAINER_PROCESSES
        else
          Etc.nprocessors
        end
      end

      # Repository path
      #
      # @return [Pathname]
      def repo_path
        TMP.join(name)
      end

      # Test if installation should be skipped
      #
      # @return [Boolean]
      def noinstall?
        ENV.key?('NOINSTALL')
      end

      # Print start progress
      #
      # @param [Pathname] path
      # @param [Integer] _index
      #
      # @return [undefined]
      #
      def start(path, _index)
        MUTEX.synchronize do
          puts START_MESSAGE % path
        end
      end

      # Print finish progress
      #
      # @param [Pathname] path
      # @param [Integer] _index
      # @param [Integer] count
      #
      # @return [undefined]
      #
      def finish(path, _index, count)
        MUTEX.synchronize do
          puts FINISH_MESSAGE % [count, path]
        end
      end

      # Helper method to execute system commands
      #
      # @param [Array<String>] arguments
      #
      # rubocop:disable GuardClause - guard clause without else does not make sense
      def system(arguments)
        return if Kernel.system(*arguments)

        if block_given?
          yield
        else
          fail "System command failed!: #{arguments.join(' ')}"
        end
      end

      # Mapping of files which we expect to cause errors during mutation generation
      class ErrorWhitelist
        class UnnecessaryExpectation < StandardError
          MESSAGE = 'Expected to encounter %s while mutating "%s"'

          def initialize(*error_info)
            super(MESSAGE % error_info)
          end
        end # UnnecessaryExpectation

        include Concord.new(:map), Adamantium

        # Assert that we expect to encounter the provided exception for this path
        #
        # @param path [Pathname]
        # @param exception [Exception]
        #
        # @raise provided exception if we are not expecting this error
        #
        # This method is reraising exceptions but rubocop can't tell
        # rubocop:disable Style/SignalException
        #
        # @return [undefined]
        def assert_error(path, exception)
          original_error = exception.cause || exception

          raise exception unless map.fetch(original_error.inspect, []).include?(path)
        end

        # Assert that we expect to not encounter an error for the specified path
        #
        # @param path [Pathname]
        #
        # @raise [UnnecessaryExpectation] if we are expecting an exception for this path
        #
        # @return [undefined]
        def assert_success(path)
          map.each do |error, paths|
            fail UnnecessaryExpectation.new(error, path) if paths.include?(path)
          end
        end

        # Return representation as hash
        #
        # @note this method is necessary for morpher loader to be invertible
        #
        # @return [Hash{Pathname => String}]
        def to_h
          map
        end
      end # ErrorWhitelist

      LOADER = Morpher.build do
        s(:block,
          s(:guard, s(:primitive, Array)),
          s(:map,
            s(:block,
              s(:guard, s(:primitive, Hash)),
              s(:hash_transform,
                s(:key_symbolize, :repo_uri,            s(:guard, s(:primitive, String))),
                s(:key_symbolize, :repo_ref,            s(:guard, s(:primitive, String))),
                s(:key_symbolize, :ruby_glob_pattern,   s(:guard, s(:primitive, String))),
                s(:key_symbolize, :name,                s(:guard, s(:primitive, String))),
                s(:key_symbolize, :namespace,           s(:guard, s(:primitive, String))),
                s(:key_symbolize, :integration,         s(:guard, s(:primitive, String))),
                s(:key_symbolize, :mutation_coverage,
                  s(:guard, s(:or, s(:primitive, TrueClass), s(:primitive, FalseClass)))),
                s(:key_symbolize, :mutation_generation,
                  s(:guard, s(:or, s(:primitive, TrueClass), s(:primitive, FalseClass)))),
                s(:key_symbolize, :expected_errors,
                  s(:block,
                    s(:guard, s(:primitive, Hash)),
                    s(:custom,
                      [
                        ->(hash) { hash.map { |key, values| [key, values.map(&Pathname.method(:new))] }.to_h },
                        ->(hash) { hash.map { |key, values| [key, values.map(&:to_s)]                 }.to_h }
                      ]),
                    s(:load_attribute_hash, s(:param, ErrorWhitelist)))),
                s(:key_symbolize, :exclude, s(:map, s(:guard, s(:primitive, String))))),
              s(:anima_load, Project))))
      end

      ALL = LOADER.call(YAML.load_file(ROOT.join('spec', 'integrations.yml')))
    end # Project
  end # Corpus
end # MutantSpec
