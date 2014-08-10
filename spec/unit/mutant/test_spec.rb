RSpec.describe Mutant::Test do
  let(:object) { described_class.new(integration, expression) }

  let(:integration) { double('Integration', name: 'test-integration') }
  let(:expression)  { double('Expression', syntax: 'test-syntax') }

  describe '#identification' do
    subject { object.identification }

    it { should eql('test-integration:test-syntax') }
  end

  describe '#run' do
    subject { object.run }

    let(:report) { double('Report') }

    it 'runs test via integration' do
      expect(integration).to receive(:run).with(object).and_return(report)
      expect(subject).to be(report)
    end
  end
end
