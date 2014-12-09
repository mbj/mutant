RSpec.describe Mutant::Reporter::Trace do
  let(:object) { described_class.new }

  describe '#delay' do
    subject { object.delay }

    it { should equal(0.0) }
  end
end
