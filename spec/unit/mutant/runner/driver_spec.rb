RSpec.describe Mutant::Parallel::Driver do
  let(:object) { described_class.new(binding) }

  let(:binding) { double('Binding') }
  let(:result)  { double('Result') }

  describe '#stop' do
    subject { object.stop }

    before do
      expect(binding).to receive(:call).with(:stop)
    end

    it_should_behave_like 'a command method'
  end

  describe '#status' do
    subject { object.status }

    before do
      expect(binding).to receive(:call).with(:status).and_return(result)
    end

    it { should be(result) }
  end
end
