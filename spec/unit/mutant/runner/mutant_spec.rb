require 'spec_helper'

describe Mutant::Runner,'#mutant' do
  subject { object.mutant }

  let(:object)           { class_under_test.run(mutation_subject, mutant) }
  let(:mutation_subject) { mock('Subject', :insert => nil, :reset => nil) }
  let(:mutant)           { mock('Mutant')                                 }

  let(:class_under_test) do
    Class.new(described_class) do
      define_method(:run) {}
    end
  end

  it_should_behave_like 'an idempotent method'

  it { should be(mutant) }
end
