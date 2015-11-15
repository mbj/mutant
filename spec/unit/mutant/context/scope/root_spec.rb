RSpec.describe Mutant::Context::Scope, '#root' do
  subject { object.root(node) }

  let(:object) { described_class.new(TestApp::Literal, path) }
  let(:path)   { instance_double(Pathname)                   }
  let(:node)   { parse(':node')                              }

  let(:scope)      { subject.body }
  let(:scope_body) { scope.body   }

  let(:expected_source) do
    generate(parse(<<-RUBY))
      module TestApp
        class Literal
          :node
        end
      end
    RUBY
  end

  let(:generated_source) do
    Unparser.unparse(subject)
  end

  let(:round_tripped_source) do
    Unparser.unparse(parse(expected_source))
  end

  it 'should create correct source' do
    expect(generated_source).to eql(expected_source)
  end
end
