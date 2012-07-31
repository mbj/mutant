require 'spec_helper'

describe Mutant::Mutatee, '#reset' do
  subject { object.reset }

  let(:object)  { described_class.new(context, ast) }
  let(:root)    { mock('Root AST') }
  let(:ast)     { mock('AST') }
  let(:context) { mock('Context', :root => root) }

  it_should_behave_like 'a command method'

  before do
    Mutant::Loader.stub(:load => Mutant::Loader)
  end

  it 'should create root ast from context' do
    context.should_receive(:root).with(ast).and_return(root)
    should be(object)
  end

  it 'should insert root ast' do
    Mutant::Loader.should_receive(:load).with(root).and_return(Mutant::Loader)
    should be(object)
  end
end
