# encoding: UTF-8

shared_examples_for 'a mutator' do
  subject { object.each(node, &yields.method(:<<)) }

  let(:yields) { []              }
  let(:object) { described_class }

  unless instance_methods.include?(:node)
    let(:node) { parse(source) }
  end

  it_should_behave_like 'a command method'

  context 'with no block' do
    subject { object.each(node) }

    it { should be_instance_of(to_enum.class) }

    def coerce(input)
      case input
      when String
        Parser::CurrentRuby.parse(input)
      when Parser::AST::Node
        input
      else
        raise
      end
    end

    def normalize(node)
      Unparser::Preprocessor.run(node)
    end

    let(:expected_mutations) do
      mutations.map(&method(:coerce)).map(&method(:normalize))
    end

    it 'generates the expected mutations' do
      generated_mutations = subject.map(&method(:normalize))

      verifier = MutationVerifier.new(node, expected_mutations, generated_mutations)

      unless verifier.success?
        fail verifier.error_report
      end
    end
  end
end

shared_examples_for 'a noop mutator' do
  let(:mutations) { [] }

  it_should_behave_like 'a mutator'
end
