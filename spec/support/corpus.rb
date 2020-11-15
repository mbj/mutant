# frozen_string_literal: true

require 'anima'
require 'mutant'
require 'parallel'

# @api private
module MutantSpec
  ROOT = Pathname.new(__FILE__).parent.parent.parent

  # Namespace module for corpus testing
  #
  # rubocop:disable Metrics/MethodLength
  module Corpus
    TMP                 = ROOT.join('tmp').freeze
    EXCLUDE_GLOB_FORMAT = '{%s}'

    # Not in the docs. Number from chatting with their support.
    # 2 processors allocated per container, 4 processes works well.
    CIRCLE_CI_CONTAINER_PROCESSES = 4

    private_constant(*constants(false))

    # Project under corpus test
    # rubocop:disable Metrics/ClassLength
    class Project
      MUTEX = Mutex.new

      MUTATION_GENERATION_MESSAGE = 'Total Mutations/Time/Parse-Errors: %s/%0.2fs - %0.2f/s'
      START_MESSAGE               = 'Starting - %s'
      FINISH_MESSAGE              = 'Mutations - %4i - %s'
      RUBY_GLOB_PATTERN           = '**/*.rb'

      DEFAULT_MUTATION_COUNT = 0

      include Adamantium, Anima.new(
        :mutation_coverage,
        :mutation_generation,
        :integration,
        :name,
        :namespace,
        :repo_uri,
        :repo_ref,
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
                bundle exec mutant run
                --use #{integration}
                --include lib
                --require #{name}
                #{namespace}*
              ] + concurrency_limits
            )
          end
        end
      end

      # The concurrency limits, if any
      #
      # @return [Array<String>]
      def concurrency_limits
        if ENV.key?('MUTANT_JOBS')
          %W[--jobs #{ENV.fetch('MUTANT_JOBS')}]
        else
          []
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
        timer = Mutant::Timer.new(Process)

        start = timer.now

        options = {
          finish:       method(:finish),
          start:        method(:start),
          in_processes: parallel_processes
        }

        total = Parallel.map(effective_ruby_paths, options, &method(:check_generation))
          .inject(DEFAULT_MUTATION_COUNT, :+)

        took = timer.now - start
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
        node = Parser::CurrentRuby.parse(path.read)
        fail "Cannot parse: #{path}" unless node

        mutations = Mutant::Mutator.mutate(node)

        mutations.each do |mutation|
          check_generation_invariants(node, mutation)
        end

        mutations.length
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
          .glob(repo_path.join(RUBY_GLOB_PATTERN))
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
      # rubocop:disable Style/GuardClause - guard clause without else does not make sense
      def system(arguments)
        return if Kernel.system(*arguments)

        if block_given?
          yield
        else
          fail "System command failed!: #{arguments.join(' ')}"
        end
      end

      Transform = Mutant::Transform

      boolean      = Transform::Boolean.new
      string       = Transform::Primitive.new(String)
      string_array = Transform::Array.new(string)

      integration = Transform::Sequence.new(
        [
          Transform::Hash.new(
            optional: [],
            required: [
              Transform::Hash::Key.new('exclude',             string_array),
              Transform::Hash::Key.new('integration',         string),
              Transform::Hash::Key.new('mutation_coverage',   boolean),
              Transform::Hash::Key.new('mutation_generation', boolean),
              Transform::Hash::Key.new('name',                string),
              Transform::Hash::Key.new('namespace',           string),
              Transform::Hash::Key.new('repo_ref',            string),
              Transform::Hash::Key.new('repo_uri',            string)
            ]
          ),
          Transform::Hash::Symbolize.new,
          Transform::Exception.new(RuntimeError, Project.method(:new))
        ]
      )

      transform =
        Transform::Sequence.new(
          [
            Transform::Exception.new(SystemCallError, :read.to_proc),
            Transform::Exception.new(YAML::SyntaxError, YAML.method(:safe_load)),
            Transform::Array.new(integration)
          ]
        )

      path = ROOT.join('spec', 'integrations.yml')

      ALL = Transform::Named
        .new(path, transform)
        .call(path)
        .lmap(&:compact_message)
        .lmap(&method(:fail))
        .from_right
    end # Project
  end # Corpus
end # MutantSpec
