# encoding: UTF-8

require 'spec_helper'

describe 'Mutant on ruby corpus' do

  ROOT = Pathname.new(__FILE__).parent.parent.parent.parent

  TMP = ROOT.join('tmp').freeze

  before do
    pending 'Corpus test is deactivated on 1.9.3' if RUBY_VERSION.eql?('1.9.3')
  end

  class Project
    include Anima.new(:name, :repo_uri, :exclude)

    # Perform verification via unparser cli
    #
    # @return [self]
    #   if successful
    #
    # @raise [Exception]
    #   otherwise
    #
    # rubocop:disable MethodLength
    def verify
      checkout
      total = 0
      parse_errors = []
      start = Time.now
      Pathname.glob(repo_path.join('**/*.rb')).sort.each do |path|
        puts "Generating mutations for: #{path}"
        begin
          node = Parser::CurrentRuby.parse(path.read)
        # Ignore known parser bugs
        rescue ArgumentError, EncodingError
          parse_errors << path
          next
        end
        next if node.nil?
        count = 0
        Mutant::Mutator::Node.each(node) do
          count += 1
          if (count % 1000).zero?
            puts count
          end
        end
        puts "Mutations: #{count}"
        total += count
      end
      took = Time.now - start
      puts format(
        'Total Mutations/Time/Parse-Errors: %s/%0.2fs/%i - %0.2f/s',
        total,
        took,
        parse_errors.size,
        total / took
      )
      if parse_errors.any?
        puts 'Files with parse errors:'
        parse_errors.each(&method(:puts))
      end
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
          system(%w[git pull origin master])
          system(%w[git clean -f -d -x])
        end
      else
        system(%W[git clone #{repo_uri} #{repo_path}])
      end
      self
    end

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

    # Helper method to execute system commands
    #
    # @param [Array<String>] arguments
    #
    # @api private
    #
    def system(arguments)
      unless Kernel.system(*arguments)
        if block_given?
          yield
        else
          raise 'System command failed!'
        end
      end
    end

    LOADER = Morpher.build do
      s(:block,
        s(:guard, s(:primitive, Array)),
        s(:map,
          s(:block,
            s(:guard, s(:primitive, Hash)),
            s(:hash_transform,
              s(:key_symbolize, :repo_uri, s(:guard, s(:primitive, String))),
              s(:key_symbolize, :name,     s(:guard, s(:primitive, String))),
              s(:key_symbolize, :exclude,  s(:map, s(:guard, s(:primitive, String))))
            ),
            s(:load_attribute_hash,
              # NOTE: The domain param has no DSL currently!
              Morpher::Evaluator::Transformer::Domain::Param.new(
                Project,
                [:repo_uri, :name, :exclude]
              )
            )
          )
        )
      )
    end

    ALL = LOADER.call(YAML.load_file(ROOT.join('spec', 'integrations.yml')))
  end

  Project::ALL.each do |project|
    specify "unparsing #{project.name}" do
      project.verify
    end
  end
end
