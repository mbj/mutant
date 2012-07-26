require 'spec_helper'

describe Mutant::Mutatee,'#each' do
  subject { object.each { |item| yields << item }   }

  let(:object)   { described_class.new(context,ast) }
  let(:root)     { mock('Root AST')                 }
  let(:ast)      { mock('AST')                      }
  let(:context)  { mock('Context', :root => root)   }
  let(:mutation) { mock('Mutation')                 }
  let(:mutator)  { [mutation]                       }
  let(:yields)   { []                               }

  before do
    Mutant::Mutator.stub(:new => mutator)
  end

  it_should_behave_like 'an #each method'

 #it 'should initialize mutator with ast' do
 #  Mutant::Mutator.should_receive(:new).with(ast).and_return(mutator)
 #end

  it 'should yield mutations' do
    expect { subject }.to change { yields.dup }.from([]).to([mutation])
  end
end
