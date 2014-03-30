# encoding: utf-8

class Subject

  include Equalizer.new(:source)

  Undefined = Object.new.freeze

  attr_reader :source

  def self.coerce(input)
    case input
    when Parser::AST::Node
      new(input)
    when String
      new(Parser::CurrentRuby.parse(input))
    else
      raise
    end
  end

  def to_s
    "#{@node.inspect}\n#{@source}"
  end

  def initialize(node)
    source = Unparser.unparse(node)
    @node, @source = node, source
  end

  def assert_transitive!
    generated = Unparser.generate(@node)
    parsed    = Parser::CurrentRuby.parse(generated)
    again     = Unparser.generate(parsed)
    unless generated == again
      # mostly an unparser bug!
      fail sprintf("Untransitive:\n%s\n---\n%s", generated, again)
    end
    self
  end
end

shared_examples_for 'a mutator' do

  unless instance_methods.include?(:config)
    let(:config)  { Mutant::Mutator::Config::DEFAULT }
  end

  let(:context) { Mutant::Mutator::Context.root(config, node) }

  subject { object.each(context) { |item| yields << item } }

  let(:yields) { []              }
  let(:object) { described_class }

  unless instance_methods.include?(:node)
    let(:node) { parse(source) }
  end

  it_should_behave_like 'a command method'

  context 'with no block' do
    subject { object.each(context) }

    it { should be_instance_of(to_enum.class) }

    let(:expected_mutations) do
      mutations.map(&Subject.method(:coerce))
    end

    it 'generates the expected mutations' do

      generated  = subject.map { |node| Subject.new(node) }

      missing    = expected_mutations - generated
      unexpected = generated - expected_mutations

      message = []

      if missing.any?
        message << sprintf('Missing mutations (%i):', missing.length)
        message.concat(missing)
      end

      if unexpected.any?
        message << sprintf('Unexpected mutations (%i):', unexpected.length)
        message.concat(unexpected)
      end

      if message.any?

        message = sprintf(
          "Original:\n%s\n%s\n-----\n%s",
          generate(node),
          node.inspect,
          message.join("\n-----\n")
        )

        fail message
      end
    end
  end
end

shared_examples_for 'a noop mutator' do
  let(:mutations) { [] }

  it_should_behave_like 'a mutator'
end
