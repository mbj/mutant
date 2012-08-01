require 'spec_helper'

describe Mutant::Runner,'.run' do
  subject { class_under_test.run(mutation_subject,mutant) }

  let(:mutation_subject) { mock('Subject', :insert => nil, :reset => nil) }
  let(:mutant)           { mock('Mutant')                                 }

  let(:class_under_test) do
    Class.new(described_class) do
      define_method(:run) {}
    end
  end

  it { should be_kind_of(class_under_test) }

  it 'should insert mutation' do
    mutation_subject.should_receive(:insert).with(mutant).and_return(mutation_subject)
    subject
  end

  it 'should reset mutation' do
    mutation_subject.should_receive(:reset).and_return(mutation_subject)
    subject
  end
end
