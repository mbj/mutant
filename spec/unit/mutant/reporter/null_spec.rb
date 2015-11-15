RSpec.describe Mutant::Reporter::Null do
  let(:object) { described_class.new     }
  let(:value)  { instance_double(Object) }

  describe '#report' do
    subject { object.report(value) }

    it_should_behave_like 'a command method'
  end

  describe '#warn' do
    subject { object.warn(value) }

    it_should_behave_like 'a command method'
  end

  describe '#progress' do
    subject { object.progress(value) }

    it_should_behave_like 'a command method'
  end
end
