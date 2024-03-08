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
        deadline:        deadline,
        io:              io,
        job:             job,
        log_reader:      log_reader,
        marshal:         marshal,
        response_reader: response_reader
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

    def select(ready)
      {
        receiver:  io,
        selector:  :select,
        arguments: [[response_reader, log_reader], nil, nil, 1.0],
        reaction:  { return: [ready] }
      }
    end

    def deadline_status(time_left: 1.0)
      {
        receiver: deadline,
        selector: :status,
        reaction: { return: Mutant::Timer::Deadline::Status.new(time_left: time_left) }
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
                job:    job,
                log:    '',
                result: result
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
                job:    job,
                log:    '',
                result: result
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
                job:    job,
                log:    '',
                result: result
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
              error:  Timeout,
              job:    job,
              log:    '<log>',
              result: nil
            )
          )
        end
      end
    end

    context 'on worker crash (eof)' do
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
              job:    job,
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
              error:  Timeout,
              job:    job,
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
              error:  Timeout,
              job:    job,
              log:    '',
              result: nil
            )
          )
        end
      end
    end

    context 'with future partial IO API changes' do
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
          }
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect { apply }.to raise_error(RuntimeError, 'Unexpected nonblocking read return: :wait_readable')
        end
      end
    end
  end
end
