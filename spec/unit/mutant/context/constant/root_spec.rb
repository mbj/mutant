require 'spec_helper'

if "".respond_to?(:to_ast) 
  describe Mutant::Context::Constant, '#root' do
    subject { object.root(node) }

    let(:object) { described_class.build(SampleSubjects::ExampleModule) }
    let(:node)   { mock('Node')                                                                          }

    let(:constant)   { subject.body }
    let(:scope)      { constant.body.first }
    let(:scope_body) { scope.body }

    it { should be_a(Rubinius::AST::Script) }

    it 'should wrap the ast under constant' do
      scope.should be_kind_of(Rubinius::AST::ModuleScope)
    end

    it 'should place the ast under scope body' do
      scope_body.should == [node]
    end
  end
end
