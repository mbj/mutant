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
      fail "Untransitive:\n%s\n---\n%s" % [generated, again]
    end
    self
  end
end

shared_examples_for 'a mutator' do
  subject { object.each(node) { |item| yields << item } }

  let(:yields) { []              }
  let(:object) { described_class }

  unless instance_methods.map(&:to_s).include?('node')
    let(:node) { parse(source) }
  end

  it_should_behave_like 'a command method'

  context 'with no block' do
    subject { object.each(node) }

    it { should be_instance_of(to_enum.class) }

    let(:expected_mutations) do
      mutations.map do |mutation|
        Subject.coerce(mutation)
      end
    end

    let(:generated_mutations) do
    end

    it 'generates the expected mutations' do
      generated  = subject.map { |node| Subject.new(node) }

      missing    = expected_mutations - generated
      unexpected = generated - expected_mutations

      message = []

      unless missing.empty?
        message << "Missing mutations (%i):" % missing.length
        message.concat(missing)
      end

      unless unexpected.empty?
        message << "Unexpected mutatiosn (%i):" % unexpected.length
        message.concat(unexpected)
      end

      fail message.join("\n-----\n") unless missing.empty? and unexpected.empty?
    end
  end
end

shared_examples_for 'a noop mutator' do
  let(:mutations) { [] }

  it_should_behave_like 'a mutator'
end
