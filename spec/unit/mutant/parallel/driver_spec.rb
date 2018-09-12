# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Driver do
  let(:object) { described_class.new(binding) }

  let(:binding) { instance_double(Mutant::Actor::Binding) }
  let(:value)   { instance_double(Object, 'value')        }

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
      expect(binding).to receive(:call).with(:status).and_return(value)
    end

    it { should be(value) }
  end
end
