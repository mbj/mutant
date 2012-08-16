require 'spec_helper'

describe Mutant::Context::Scope, '#root' do
  subject { object.root(node) }

  let(:object) { described_class.build(TestApp::Literal, path) }
  let(:path)   { mock('Path') }
  let(:node)   { mock('Node') } 

  let(:constant)   { subject.body  }
  let(:scope)      { constant.body }
  let(:scope_body) { scope.body    }

  it { should be_a(Rubinius::AST::Script) }
  its(:file) { should be(path) }

  it 'should wrap the ast under constant' do
    scope.should be_kind_of(Rubinius::AST::ClassScope)
  end

  it 'should place the ast under scope inside of block' do
    scope_body.should be_a(Rubinius::AST::Block)
    scope_body.array.should eql([node])
    scope_body.array.first.should be(node)
  end
end
