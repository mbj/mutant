RSpec.describe Mutant::Reporter::Trace do
  let(:object) { described_class.new }

  describe '#delay' do
    subject { object.delay }

    it { should eql(0.0) }
  end
end
