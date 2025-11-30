# frozen_string_literal: true

require 'etc'
require 'mutant'
require 'parallel'

# @api private
module MutantSpec
  ROOT = Pathname.new(__FILE__).parent.parent.parent

  # Namespace module for corpus testing
  #
  # rubocop:disable Metrics/MethodLength
  module Corpus
    TMP = ROOT.join('tmp').freeze

    private_constant(*constants(false))

    # Project under corpus test
    # rubocop:disable Metrics/ClassLength
    class Project
      MUTEX = Mutex.new

      MUTATION_GENERATION_MESSAGE = 'Total Mutations/Time/Parse-Errors: %s/%0.2fs - %0.2f/s'
      FINISH_MESSAGE              = '%4i - %s'
      RUBY_GLOB_PATTERN           = '**/*.rb'

      include Adamantium, Anima.new(
        :mutation_coverage,
        :mutation_generation,
        :integration_name,
        :name,
        :namespace,
        :repo_uri,
        :repo_ref,
        :exclude,
        :extra_flags,
        :include_path,
        :require_path
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
          Bundler.with_unbundled_env do
            install_mutant
            system(
              %W[
                bundle exec mutant run
                --integration #{integration_name}
                --include #{include_path}
                --require #{require_path}
                --usage opensource
              ] + concurrency_limits + extra_flags + %W[#{namespace}*]
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

      class Sink
        include Mutant::Parallel::Sink

        attr_reader :total

        def initialize
          @total = 0
        end

        def stop?
          false
        end

        def status
          @total
        end

        def response(response)
          if response.error
            Mutant::WORLD.stderr.puts(response.log)
            fail response.error
          end
          puts(FINISH_MESSAGE % [response.result, response.job.payload])
          @total += response.result
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

        sink = Sink.new

        elapsed = Mutant::WORLD.timer.elapsed do
          driver = Mutant::Parallel.async(
            config: parallel_config(sink),
            world:  Mutant::WORLD
          )

          loop do
            status = driver.wait_timeout(1)
            break if status.done?
          end
        end

        puts MUTATION_GENERATION_MESSAGE % [sink.total, elapsed, sink.total / elapsed]
        self
      end

      def parallel_config(sink)
        Mutant::Parallel::Config.new(
          block:            method(:check_generation),
          jobs:             Etc.nprocessors,
          sink:,
          timeout:          nil,
          process_name:     'mutation-generation',
          source:           Mutant::Parallel::Source::Array.new(jobs: effective_ruby_paths),
          on_process_start: ->(_) {},
          thread_name:      'mutation-generation'
        )
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
        begin
          node = Unparser.parse(path.read) or return 0
        # no need to generate mutation if the source is invalid
        rescue Parser::SyntaxError
          return 0
        end

        mutations = Mutant::Mutator::Node.mutate(
          config: Mutant::Mutation::Config::DEFAULT.with(operators: Mutant::Mutation::Operators::Full.new),
          node:
        )

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

        Unparser::Diff.build(original_source, mutation_source) and return

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

      # Repository path
      #
      # @return [Pathname]
      def repo_path
        TMP.join("#{name}-#{Digest::SHA256.hexdigest(inspect)}")
      end

      # Test if installation should be skipped
      #
      # @return [Boolean]
      def noinstall?
        ENV.key?('NOINSTALL')
      end

      # Helper method to execute system commands
      #
      # @param [Array<String>] arguments
      #
      # rubocop:disable Style/GuardClause
      # ^^ guard clause without else does not make sense
      def system(arguments)
        return if Kernel.system(*arguments)

        if block_given?
          yield
        else
          fail "System command failed!: #{arguments.join(' ')}"
        end
      end

      Transform = Mutant::Transform

      integration = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new(
                transform: Transform::STRING_ARRAY,
                value:     'extra_flags'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'include_path'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'require_path'
              )
            ],
            required: [
              Transform::Hash::Key.new(
                transform: Transform::STRING_ARRAY,
                value:     'exclude'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'integration_name'
              ),
              Transform::Hash::Key.new(
                transform: Transform::BOOLEAN,
                value:     'mutation_coverage'
              ),
              Transform::Hash::Key.new(
                transform: Transform::BOOLEAN,
                value:     'mutation_generation'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'name'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'namespace'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'repo_ref'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'repo_uri'
              )
            ]
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(
            block: lambda { |attributes|
              attributes = attributes.merge(extra_flags: []) unless attributes.key?(:extra_flags)
              attributes = attributes.merge(include_path: 'lib') unless attributes.key?(:include_path)
              attributes = attributes.merge(require_path: attributes[:name]) unless attributes.key?(:require_path)
              attributes
            }
          ),
          Transform::Exception.new(error_class: RuntimeError, block: Project.public_method(:new))
        ]
      )

      transform =
        Transform::Sequence.new(
          steps: [
            Transform::Exception.new(error_class: SystemCallError,   block: :read.to_proc),
            Transform::Exception.new(error_class: YAML::SyntaxError, block: YAML.public_method(:safe_load)),
            Transform::Array.new(transform: integration)
          ]
        )

      path = ROOT.join('spec', 'integrations.yml')

      ALL = Transform::Named
        .new(name: path, transform:)
        .call(path)
        .lmap(&:compact_message)
        .lmap(&method(:fail))
        .from_right
    end # Project
  end # Corpus
end # MutantSpec
