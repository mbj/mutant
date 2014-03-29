require 'spec_helper'

describe Mutant::WarningFilter do
  let(:object) { described_class.new(target) }

  let(:target) do
    writes = self.writes
    Module.new do
      define_singleton_method :write do |message|
        writes << message
      end
    end
  end

  let(:writes) { [] }

  describe '#write' do
    subject { object.write(message) }

    context 'when writing a non warning message' do
      let(:message) { 'foo' }

      it 'writes message' do
        expect { subject }.to change { writes }.from([]).to([message])
      end

      it 'does not capture warning' do
        subject
        expect(subject.warnings).to eql([])
      end
    end

    context 'when writing a warning message' do
      let(:message) { "test.rb:1: warning: some warning\n" }

      it 'captures warning' do
        expect { subject }.to change { object.warnings }.from([]).to([message])
      end

      it 'does not write message' do
        subject
        expect(writes).to eql([])
      end
    end
  end
end
