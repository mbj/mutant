# encoding: UTF-8

require 'spec_helper'

describe 'Mutant on ruby corpus' do
  ROOT = Pathname.new(__FILE__).parent.parent.parent.parent

  TMP = ROOT.join('tmp')

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
    def verify
      checkout
      Pathname.glob(repo_path.join('**/*.rb')).sort.each do |path|
        puts "Generating mutations for: #{path.to_s}"
        node = Parser::CurrentRuby.parse(path.read)
        count = 0
        Mutant::Mutator::Node.each(node) do |mutant|
          count += 1
          if (count % 100).zero?
            puts count
          end
        end
        puts "Mutations: #{count}"
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
          system(%w(git pull origin master))
          system(%w(git clean -f -d -x))
        end
      else
        system(%W(git clone #{repo_uri} #{repo_path}))
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
