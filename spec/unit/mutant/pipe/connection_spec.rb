# frozen_string_literal: true

RSpec.describe Mutant::Pipe::Connection do
  let(:marshal)        { class_double(Marshal) }
  let(:request)        { 1                     }
  let(:request_bytes)  { 'request-bytes'       }
  let(:response)       { 2                     }
  let(:response_bytes) { 'response-bytes'      }

  let(:pipe_a) do
    instance_double(
      Mutant::Pipe,
      to_reader: instance_double(IO, :reader_a),
      to_writer: instance_double(IO, :writer_a)
    )
  end

  let(:pipe_b) do
    instance_double(
      Mutant::Pipe,
      to_reader: instance_double(IO, :reader_b),
      to_writer: instance_double(IO, :writer_b)
    )
  end

  let(:object) do
    described_class.from_pipes(
      marshal: marshal,
      reader:  pipe_a,
      writer:  pipe_b
    )
  end

  let(:read_header) do
    [
      {
        receiver: pipe_a.to_reader,
        selector: :binmode
      },
      {
        receiver:  pipe_a.to_reader,
        selector:  :read,
        arguments: [4],
        reaction:  { return: [response_bytes.bytesize].pack('N') }
      }
    ]
  end

  let(:send_request) do
    [
      {
        receiver:  marshal,
        selector:  :dump,
        arguments: [request],
        reaction:  { return: request_bytes }
      },
      {
        receiver: pipe_b.to_writer,
        selector: :binmode
      },
      {
        receiver:  pipe_b.to_writer,
        selector:  :write,
        arguments: [[request_bytes.bytesize].pack('N')]
      },
      {
        receiver:  pipe_b.to_writer,
        selector:  :write,
        arguments: [request_bytes]
      }
    ]
  end

  let(:receive_response) do
    [
      *read_header,
      {
        receiver: pipe_a.to_reader,
        selector: :binmode
      },
      {
        receiver:  pipe_a.to_reader,
        selector:  :read,
        arguments: [response_bytes.bytesize],
        reaction:  { return: response_bytes }
      },
      {
        receiver:  marshal,
        selector:  :load,
        arguments: [response_bytes],
        reaction:  { return: response }
      }
    ]
  end

  describe '#send_value' do
    def apply
      object.send_value(request)
    end

    let(:raw_expectations) { send_request }

    context 'on frame size within max frame size' do
      it 'expected events' do
        verify_events { expect(apply).to be(object) }
      end
    end

    context 'on frame size outside max frame size' do
      let(:request_bytes) { instance_double(String, bytesize: 4**32) }

      let(:raw_expectations) do
        [
          {
            receiver:  marshal,
            selector:  :dump,
            arguments: [request],
            reaction:  { return: request_bytes }
          }
        ]
      end

      it 'expected events' do
        verify_events do
          expect { apply }.to raise_error(described_class::Error, 'message to big')
        end
      end
    end
  end

  describe '#receive_value' do
    def apply
      object.receive_value
    end

    context 'without unexpected EOF' do
      let(:raw_expectations) { receive_response }

      it 'performs expected events' do
        verify_events { expect(apply).to be(response) }
      end
    end

    context 'with unexpected EOF' do
      context 'in header' do
        let(:raw_expectations) do
          [
            {
              receiver: pipe_a.to_reader,
              selector: :binmode
            },
            {
              receiver:  pipe_a.to_reader,
              selector:  :read,
              arguments: [4],
              reaction:  { return: nil }
            }
          ]
        end

        it 'raises connection error' do
          verify_events do
            expect { apply }.to raise_error(described_class::Error, 'Unexpected EOF')
          end
        end
      end

      context 'in body' do
        let(:raw_expectations) do
          [
            *read_header,
            {
              receiver: pipe_a.to_reader,
              selector: :binmode
            },
            {
              receiver:  pipe_a.to_reader,
              selector:  :read,
              arguments: [response_bytes.bytesize],
              reaction:  { return: nil }
            }
          ]
        end

        it 'raises connection error' do
          verify_events do
            expect { apply }.to raise_error(described_class::Error, 'Unexpected EOF')
          end
        end
      end
    end
  end

  describe '#call' do
    def apply
      object.call(request)
    end

    let(:raw_expectations) do
      [
        *send_request,
        *receive_response
      ]
    end

    it 'performs expected events' do
      verify_events do
        expect(apply).to eql(response)
      end
    end
  end

  describe '.from_pipes' do
    it 'returns expected connection' do
      expect(object).to eql(
        described_class.new(
          marshal: marshal,
          reader:  described_class::Frame.new(pipe_a.to_reader),
          writer:  described_class::Frame.new(pipe_b.to_writer)
        )
      )
    end
  end
end
