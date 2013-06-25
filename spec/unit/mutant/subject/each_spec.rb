require 'spec_helper'

describe Mutant::Subject, '#each' do
  subject { object.each { |item| yields << item } }

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object)   { class_under_test.new(context, ast) }
  let(:root)     { mock('Root Node')                  }
  let(:ast)      { mock('Node')                       }
  let(:context)  { mock('Context', :root => root)     }
  let(:mutant)   { mock('Mutant')                     }
  let(:mutation) { mock('Mutation')                   }
  let(:yields)   { []                                 }

  before do
    Mutant::Mutator.stub(:each).with(ast).and_yield(mutant).and_return(Mutant::Mutator)
    Mutant::Mutation.stub(:new => mutation)
  end

  it_should_behave_like 'an #each method'

  it 'should initialize mutator with ast' do
    Mutant::Mutator.should_receive(:each).with(ast).and_yield(mutation).and_return(Mutant::Mutator)
    subject
  end

  it 'should yield mutations' do
    expect { subject }.to change { yields.dup }.from([]).to([mutation])
  end

  it 'should initialize mutation' do
    Mutant::Mutation.should_receive(:new).with(object, mutant).and_return(mutation)
    subject
  end
end
