# frozen_string_literal: true

RSpec.describe Mutant::Actor::Receiver do
  let(:messages)           { instance_double(Array)             }
  let(:mutex)              { instance_double(Mutex)             }
  let(:condition_variable) { instance_double(ConditionVariable) }
  let(:message)            { instance_double(Object)            }

  let(:object) { described_class.new(condition_variable, mutex, messages) }

  describe '#call' do
    subject { object.call }

    context 'when messages contains a message' do
      before do
        expect(mutex).to receive(:synchronize).and_yield.ordered
        expect(messages).to receive(:empty?).and_return(false).ordered
        expect(messages).to receive(:shift).and_return(message).ordered
      end

      it { should be(message) }
    end

    context 'when messages initially contains no message' do
      before do
        # 1rst failing try
        expect(mutex).to receive(:synchronize).and_yield.ordered
        expect(messages).to receive(:empty?).and_return(true).ordered
        expect(condition_variable).to receive(:wait).with(mutex).ordered
        # 2nd successful try
        expect(mutex).to receive(:synchronize).and_yield.ordered
        expect(messages).to receive(:empty?).and_return(false).ordered
        expect(messages).to receive(:shift).and_return(message).ordered
      end

      it 'waits for message' do
        should be(message)
      end
    end

    context 'when messages contains no message but thread gets waken without message arrived' do
      before do
        # 1rst failing try
        expect(mutex).to receive(:synchronize).and_yield.ordered
        expect(messages).to receive(:empty?).and_return(true).ordered
        expect(condition_variable).to receive(:wait).with(mutex).ordered
        # 2nd failing try
        expect(mutex).to receive(:synchronize).and_yield.ordered
        expect(messages).to receive(:empty?).and_return(true).ordered
        expect(condition_variable).to receive(:wait).with(mutex).ordered
      end

      it 'fails with error' do
        expect { subject }.to raise_error(Mutant::Actor::ProtocolError)
      end
    end
  end
end
