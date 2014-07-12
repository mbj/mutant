require 'spec_helper'

describe Mutant::Integration do

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object) { class_under_test.new }

  describe '#all_tests' do
    subject { object.all_tests }

    it { should eql([]) }
    it_should_behave_like 'an idempotent method'
  end

  describe '#setup' do
    subject { object.setup }
    it_should_behave_like 'a command method'
  end
end
