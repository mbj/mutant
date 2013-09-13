require 'spec_helper'

describe Mutant::Strategy do

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object) { class_under_test.new }

  describe '#teardown' do
    subject { object.teardown }
    it_should_behave_like 'a command method'
  end

  describe '#setup' do
    subject { object.setup }
    it_should_behave_like 'a command method'
  end
end

