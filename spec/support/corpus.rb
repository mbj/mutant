require 'morpher'
require 'anima'
require 'mutant'

# @api private
module MutantSpec
  ROOT = Pathname.new(__FILE__).parent.parent.parent

  # Namespace module for corpus testing
  #
  # rubocop:disable MethodLength
  module Corpus
    TMP                 = ROOT.join('tmp').freeze
    EXCLUDE_GLOB_FORMAT = '{%s}'.freeze
    RUBY_GLOB_PATTERN   = '**/*.rb'.freeze

    # Not in the docs. Number from chatting with their support.
    # 2 processors allocated per container, 4 processes works well.
    CIRCLE_CI_CONTAINER_PROCESSES = 4

    private_constant(*constants(false))

    # Project under corpus test
    # rubocop:disable ClassLength
    class Project
      MUTEX = Mutex.new

      MUTATION_GENERATION_MESSAGE = 'Total Mutations/Time/Parse-Errors: %s/%0.2fs - %0.2f/s'.freeze
      START_MESSAGE               = 'Starting - %s'.freeze
      FINISH_MESSAGE              = 'Mutations - %4i - %s'.freeze

      include Adamantium, Anima.new(
        :exclude,
        :expect_coverage,
        :mutation_coverage,
        :mutation_generation,
        :name,
        :namespace,
        :repo_uri
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
                --use rspec
                --include lib
                --require #{name}
                --expected-coverage #{expect_coverage}
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
        start = Time.now

        options = {
          finish:       method(:finish),
          start:        method(:start),
          in_processes: parallel_processes
        }
        total = Parallel.map(effective_ruby_paths, options) do |path|
          count = 0
          node =
            begin
              Parser::CurrentRuby.parse(path.read)
            rescue EncodingError, ArgumentError
              nil # Make rubocop happy
            end

          if node
            count += Mutant::Mutator::REGISTRY.call(node).length
          end

          count
        end.inject(0, :+)
        took = Time.now - start
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
            system(%w[git checkout origin/master])
            system(%w[git reset --hard])
            system(%w[git clean -f -d -x])
          end
        else
          system(%W[git clone #{repo_uri} #{repo_path}])
        end
        self
      end
      memoize :checkout

    private

      # Install mutant
      #
      # @return [undefined]
      def install_mutant
        return if noinstall?
        relative = ROOT.relative_path_from(repo_path)
        repo_path.join('Gemfile').open('a') do |file|
          file << "gem 'mutant', path: '#{relative}'\n"
          file << "gem 'mutant-rspec', path: '#{relative}'\n"
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
        paths = Pathname
          .glob(repo_path.join(RUBY_GLOB_PATTERN))
          .sort_by(&:size)
          .reverse

        paths - excluded_paths
      end

      # The excluded file paths
      #
      # @return [Array<Pathname>]
      def excluded_paths
        Pathname.glob(repo_path.join(EXCLUDE_GLOB_FORMAT % exclude.join(',')))
      end

      # Number of parallel processes to use
      #
      # @return [Fixnum]
      def parallel_processes
        if ENV.key?('CI')
          CIRCLE_CI_CONTAINER_PROCESSES
        else
          Parallel.processor_count
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
      # @param [Fixnum] _index
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
      # @param [Fixnum] _index
      # @param [Fixnum] count
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

      # rubocop:disable ClosingParenthesisIndentation
      LOADER = Morpher.build do
        s(:block,
          s(:guard, s(:primitive, Array)),
          s(:map,
            s(:block,
              s(:guard, s(:primitive, Hash)),
              s(:hash_transform,
                s(:key_symbolize, :repo_uri,            s(:guard, s(:primitive, String))),
                s(:key_symbolize, :name,                s(:guard, s(:primitive, String))),
                s(:key_symbolize, :namespace,           s(:guard, s(:primitive, String))),
                s(:key_symbolize, :expect_coverage,     s(:guard, s(:primitive, Fixnum))),
                s(:key_symbolize, :mutation_coverage,
                  s(:guard, s(:or, s(:primitive, TrueClass), s(:primitive, FalseClass)))),
                s(:key_symbolize, :mutation_generation,
                  s(:guard, s(:or, s(:primitive, TrueClass), s(:primitive, FalseClass)))),
                s(:key_symbolize, :exclude,             s(:map, s(:guard, s(:primitive, String))))
              ),
              s(:load_attribute_hash,
                # NOTE: The domain param has no DSL currently!
                Morpher::Evaluator::Transformer::Domain::Param.new(
                  Project,
                  %i[repo_uri name exclude mutation_coverage mutation_generation]
                )
              )
            )
          )
        )
      end

      ALL = LOADER.call(YAML.load_file(ROOT.join('spec', 'integrations.yml')))
    end # Project
  end # Corpus
end # MutantSpec
