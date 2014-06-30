# encoding: UTF-8

require 'parallel'
require 'spec_helper'

describe 'Mutant on ruby corpus' do

  ROOT = Pathname.new(__FILE__).parent.parent.parent.parent

  TMP = ROOT.join('tmp').freeze

  before do
    skip 'Corpus test is deactivated on 1.9.3' if RUBY_VERSION.eql?('1.9.3')
    skip 'Corpus test is deactivated on RBX' if RUBY_ENGINE.eql?('rbx')
  end

  MUTEX = Mutex.new

  class Project
    include Adamantium, Anima.new(
      :name,
      :repo_uri,
      :exclude,
      :mutation_coverage,
      :mutation_generation,
      :namespace,
      :expect_coverage
    )

    # Verify mutation coverage
    #
    # @return [self]
    #   if successufl
    #
    # @raise [Exception]
    #
    def verify_mutation_coverage
      checkout
      Dir.chdir(repo_path) do
        relative = ROOT.relative_path_from(repo_path)
        devtools = ROOT.join('Gemfile.devtools').read
        devtools << "gem 'mutant', path: '#{relative}'\n"
        devtools << "gem 'mutant-rspec', path: '#{relative}'\n"
        File.write(repo_path.join('Gemfile.devtools'), devtools)
        lockfile = repo_path.join('Gemfile.lock')
        lockfile.delete if lockfile.exist?
        Bundler.with_clean_env do
          system('bundle install')
          system(%W[bundle exec mutant -I lib -r #{name} --score #{expect_coverage} --use rspec #{namespace}*])
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
    #
    # rubocop:disable MethodLength
    def verify_mutation_generation
      checkout
      start = Time.now
      paths = Pathname.glob(repo_path.join('**/*.rb')).sort_by(&:size).reverse
      total = Parallel.map(paths, finish: method(:finish), start: method(:start)) do |path|
        count = 0
        node =
          begin
            Parser::CurrentRuby.parse(path.read)
          rescue EncodingError, ArgumentError
            nil # Make rubocop happy
          end
        if node
          Mutant::Mutator::Node.each(node) do
            count += 1
          end
        end
        count
      end.inject(0, :+)
      took = Time.now - start
      puts format(
        'Total Mutations/Time/Parse-Errors: %s/%0.2fs - %0.2f/s',
        total,
        took,
        total / took
      )
      self
    end

    # Checkout repository
    #
    # @return [self]
    #
    # @api private
    #
    def checkout
      TMP.mkdir unless TMP.directory?
      if repo_path.exist?
        Dir.chdir(repo_path) do
          system(%w[git pull -f origin master])
          system(%w[git clean -f -d -x])
        end
      else
        system(%W[git clone #{repo_uri} #{repo_path}])
      end
      self
    end
    memoize :checkout

  private

    # Return repository path
    #
    # @return [Pathname]
    #
    # @api private
    #
    def repo_path
      TMP.join(name)
    end

    # Print start progress
    #
    # @param [Pathname] path
    # @param [Fixnum] _index
    # @param [Fixnum] count
    #
    # @return [undefined]
    #
    def start(path, _index)
      MUTEX.synchronize do
        puts format('Starting - %s', path)
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
        puts format('Mutations - %4i - %s', count, path)
      end
    end

    # Helper method to execute system commands
    #
    # @param [Array<String>] arguments
    #
    # @api private
    #
    def system(arguments)
      return if Kernel.system(*arguments)
      if block_given?
        yield
      else
        raise 'System command failed!'
      end
    end

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
              s(:key_symbolize, :expect_coverage,     s(:guard, s(:primitive, Float))),
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
                [:repo_uri, :name, :exclude, :mutation_coverage, :mutation_generation]
              )
            )
          )
        )
      )
    end

    ALL = LOADER.call(YAML.load_file(ROOT.join('spec', 'integrations.yml')))
  end

  Project::ALL.select(&:mutation_generation).each do |project|
    specify "#{project.name} does not fail on mutation generation" do
      project.verify_mutation_generation
    end
  end

  Project::ALL.select(&:mutation_coverage).each do |project|
    specify "#{project.name} does have expected mutaiton coverage" do
      project.verify_mutation_coverage
    end
  end
end
