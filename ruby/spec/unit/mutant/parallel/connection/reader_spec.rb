# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Connection::Reader do
  let(:deadline)        { instance_double(Mutant::Timer::Deadline)                  }
  let(:header_segment)  { [result_segment.bytesize].pack('N')                       }
  let(:io)              { class_double(IO)                                          }
  let(:job)             { Mutant::Parallel::Source::Job.new(index: 0, payload: nil) }
  let(:log_reader)      { instance_double(IO)                                       }
  let(:marshal)         { class_double(Marshal)                                     }
  let(:response_reader) { instance_double(IO)                                       }
  let(:result)          { double('reader-result')                                   }
  let(:result_segment)  { '<result-segment>'                                        }

  describe '.read_response' do
    def apply
      described_class.read_response(
        deadline:,
        io:,
        job:,
        log_reader:,
        marshal:,
        response_reader:
      )
    end

    def binmode(io)
      {
        receiver: io,
        selector: :binmode
      }
    end

    def read(io:, bytes:, chunk:)
      {
        receiver:  io,
        selector:  :read_nonblock,
        arguments: [bytes, { exception: false }],
        reaction:  { return: chunk }
      }
    end

    def select(ready, readers: [response_reader, log_reader])
      {
        receiver:  io,
        selector:  :select,
        arguments: [readers, nil, nil, 1.0],
        reaction:  { return: [ready] }
      }
    end

    def deadline_status(time_left: 1.0)
      {
        receiver: deadline,
        selector: :status,
        reaction: { return: Mutant::Timer::Deadline::Status.new(time_left:) }
      }
    end

    def marshal_load
      {
        receiver:  marshal,
        selector:  :load,
        arguments: [result_segment],
        reaction:  { return: result }
      }
    end

    context 'on result' do
      context 'with nil result' do
        let(:result) { nil }

        let(:raw_expectations) do
          [
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 4, chunk: header_segment),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes: result_segment.bytesize,
              chunk: result_segment,
              io:    response_reader
            ),
            marshal_load
          ]
        end

        it 'returns parallel result' do
          verify_events do
            expect(apply).to eql(
              Mutant::Parallel::Response.new(
                error:  nil,
                job:,
                log:    '',
                result:
              )
            )
          end
        end
      end
      context 'with full reads' do
        let(:raw_expectations) do
          [
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 4, chunk: header_segment),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes: result_segment.bytesize,
              chunk: result_segment,
              io:    response_reader
            ),
            marshal_load
          ]
        end

        it 'returns parallel result' do
          verify_events do
            expect(apply).to eql(
              Mutant::Parallel::Response.new(
                error:  nil,
                job:,
                log:    '',
                result:
              )
            )
          end
        end
      end

      context 'with partial reads' do
        let(:raw_expectations) do
          [
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 4, chunk: header_segment[0..1]),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 2, chunk: header_segment[2..]),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes: result_segment.bytesize,
              chunk: result_segment,
              io:    response_reader
            ),
            marshal_load
          ]
        end

        it 'returns parallel result' do
          verify_events do
            expect(apply).to eql(
              Mutant::Parallel::Response.new(
                error:  nil,
                job:,
                log:    '',
                result:
              )
            )
          end
        end
      end
    end

    context 'on IO timeout with log' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([log_reader]),
          binmode(log_reader),
          read(
            io:    log_reader,
            bytes: 4096,
            chunk: '<log>'
          ),
          deadline_status,
          select(nil)
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  Timeout::Error,
              job:,
              log:    '<log>',
              result: nil
            )
          )
        end
      end
    end

    context 'on worker crash (eof) during header read' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(
            bytes: 4,
            io:    response_reader,
            chunk: nil
          )
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  EOFError,
              job:,
              log:    '',
              result: nil
            )
          )
        end
      end
    end

    context 'on worker crash (eof) during body read' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(io: response_reader, bytes: 4, chunk: header_segment),
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(
            bytes: result_segment.bytesize,
            io:    response_reader,
            chunk: nil
          )
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  EOFError,
              job:,
              log:    '',
              result: nil
            )
          )
        end
      end
    end

    context 'on IO timeout' do
      let(:raw_expectations) do
        [
          deadline_status,
          select(nil)
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  Timeout::Error,
              job:,
              log:    '',
              result: nil
            )
          )
        end
      end
    end

    context 'on CPU timeout' do
      let(:raw_expectations) do
        [
          deadline_status(time_left: 0)
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  Timeout::Error,
              job:,
              log:    '',
              result: nil
            )
          )
        end
      end
    end

    context 'when read_nonblock returns :wait_readable then succeeds' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          {
            receiver:  response_reader,
            selector:  :read_nonblock,
            arguments: [4, { exception: false }],
            reaction:  { return: :wait_readable }
          },
          # After :wait_readable, loop continues and retries
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(io: response_reader, bytes: 4, chunk: header_segment),
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(
            bytes: result_segment.bytesize,
            chunk: result_segment,
            io:    response_reader
          ),
          marshal_load
        ]
      end

      it 'retries and returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  nil,
              job:,
              log:    '',
              result:
            )
          )
        end
      end
    end

    context 'when read_nonblock returns :wait_writable then succeeds' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          {
            receiver:  response_reader,
            selector:  :read_nonblock,
            arguments: [4, { exception: false }],
            reaction:  { return: :wait_writable }
          },
          # After :wait_writable, loop continues and retries
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(io: response_reader, bytes: 4, chunk: header_segment),
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(
            bytes: result_segment.bytesize,
            chunk: result_segment,
            io:    response_reader
          ),
          marshal_load
        ]
      end

      it 'retries and returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  nil,
              job:,
              log:    '',
              result:
            )
          )
        end
      end
    end

    context 'when read_nonblock returns unexpected value' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          {
            receiver:  response_reader,
            selector:  :read_nonblock,
            arguments: [4, { exception: false }],
            reaction:  { return: :unexpected_symbol }
          }
        ]
      end

      it 'raises an error with the unexpected value' do
        verify_events do
          expect { apply }.to raise_error(
            RuntimeError,
            'Unexpected nonblocking read return: :unexpected_symbol'
          )
        end
      end
    end

    context 'when log reader hits EOF then response succeeds' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([log_reader]),
          binmode(log_reader),
          read(io: log_reader, bytes: 4096, chunk: nil),
          # After log EOF, log_reader is removed from readers
          deadline_status,
          select([response_reader], readers: [response_reader]),
          binmode(response_reader),
          read(io: response_reader, bytes: 4, chunk: header_segment),
          deadline_status,
          select([response_reader], readers: [response_reader]),
          binmode(response_reader),
          read(
            bytes: result_segment.bytesize,
            chunk: result_segment,
            io:    response_reader
          ),
          marshal_load
        ]
      end

      it 'removes log reader and returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  nil,
              job:,
              log:    '',
              result:
            )
          )
        end
      end
    end
  end
end
