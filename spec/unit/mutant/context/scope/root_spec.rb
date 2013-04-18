require 'spec_helper'

describe Mutant::Context::Scope, '#root' do
  subject { object.root(node) }

  let(:object) { described_class.new(TestApp::Literal, path) }
  let(:path)   { mock('Path') }
  let(:node)   { ':node'.to_ast }

  let(:scope)      { subject.body }
  let(:scope_body) { scope.body    }

  let(:expected_source) do
    ToSource.to_source(<<-RUBY.to_ast)
      module TestApp
        class Literal
          :node
        end
      end
    RUBY
  end

  let(:generated_source) do
    ToSource.to_source(subject)
  end

  let(:round_tripped_source) do
    ToSource.to_source(expected_source.to_ast)
  end

  it 'should create correct source' do
    generated_source.should eql(expected_source)
  end
end
