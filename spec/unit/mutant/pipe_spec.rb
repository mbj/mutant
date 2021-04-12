# frozen_string_literal: true

RSpec.describe Mutant::Pipe do
  let(:io)     { class_double(IO)        }
  let(:reader) { instance_double(IO, :a) }
  let(:writer) { instance_double(IO, :a) }

  subject { described_class.new(reader: reader, writer: writer) }

  describe '.from_io' do
    def apply
      described_class.from_io(io)
    end

    let(:raw_expectations) do
      [
        {
          receiver:  io,
          selector:  :pipe,
          arguments: [{ binmode: true }],
          reaction:  { return: [reader, writer] }
        }
      ]
    end

    it 'returns expected pipe' do
      verify_events do
        expect(apply).to eql(described_class.new(reader: reader, writer: writer))
      end
    end
  end

  describe '.with' do
    let(:yields) { [] }

    def apply
      described_class.with(io, &yields.public_method(:<<))
    end

    let(:raw_expectations) do
      [
        {
          receiver:  io,
          selector:  :pipe,
          arguments: [{ binmode: true }],
          reaction:  { yields: [[reader, writer]] }
        }
      ]
    end

    it 'yields new pipe' do
      verify_events do
        expect { apply }.to change(yields, :to_a).from([]).to([subject])
      end
    end
  end

  describe '#to_reader' do
    def apply
      subject.to_reader
    end

    let(:raw_expectations) do
      [
        {
          receiver: writer,
          selector: :close
        }
      ]
    end

    it 'returns reader after closing writer' do
      verify_events do
        expect(apply).to be(reader)
      end
    end
  end

  describe '#to_writer' do
    def apply
      subject.to_writer
    end

    let(:raw_expectations) do
      [
        {
          receiver: reader,
          selector: :close
        }
      ]
    end

    it 'returns writer after closing reader' do
      verify_events do
        expect(apply).to be(writer)
      end
    end
  end
end
