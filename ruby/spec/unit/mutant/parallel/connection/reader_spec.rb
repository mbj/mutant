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

    def read(io:, bytes:, return_value:)
      {
        receiver:  io,
        selector:  :read_nonblock,
        arguments: [bytes, { exception: false }],
        reaction:  { return: return_value }
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
            read(io: response_reader, bytes: 4, return_value: header_segment),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes:        result_segment.bytesize,
              return_value: result_segment,
              io:           response_reader
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
            read(io: response_reader, bytes: 4, return_value: header_segment),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes:        result_segment.bytesize,
              return_value: result_segment,
              io:           response_reader
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
            read(io: response_reader, bytes: 4, return_value: header_segment[0..1]),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 2, return_value: header_segment[2..]),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes:        result_segment.bytesize,
              return_value: result_segment,
              io:           response_reader
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

      # this is a behavior observed on ruby-4 the FD signals being ready via
      # select but read attempts still return :wait_readable, mutant will simply
      # circle around and consider the interaction a partial (but 0 byte) read
      # waiting again on select
      context 'with ready signal on FD that is not actually ready' do
        let(:raw_expectations) do
          [
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 4, return_value: :wait_readable),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(io: response_reader, bytes: 4, return_value: header_segment),
            deadline_status,
            select([response_reader]),
            binmode(response_reader),
            read(
              bytes:        result_segment.bytesize,
              return_value: result_segment,
              io:           response_reader
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

    context 'on error reading logs' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([log_reader]),
          binmode(log_reader),
          read(
            io:           log_reader,
            bytes:        4096,
            return_value: nil
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

    context 'on error reading lots of logs' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([log_reader]),
          binmode(log_reader),
          read(
            io:           log_reader,
            bytes:        4096,
            return_value: 'a' * 4096
          ),
          binmode(log_reader),
          read(
            io:           log_reader,
            bytes:        4096,
            return_value: nil
          )
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect(apply).to eql(
            Mutant::Parallel::Response.new(
              error:  EOFError,
              job:,
              log:    'a' * 4096,
              result: nil
            )
          )
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
            io:           log_reader,
            bytes:        4096,
            return_value: '<log>'
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

    context 'on worker crash (eof)' do
      let(:raw_expectations) do
        [
          deadline_status,
          select([response_reader]),
          binmode(response_reader),
          read(
            bytes:        4,
            io:           response_reader,
            return_value: nil
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
            reaction:  { return: :unknown_future }
          }
        ]
      end

      it 'returns parallel result' do
        verify_events do
          expect { apply }.to raise_error(RuntimeError, 'Unexpected nonblocking read return: :unknown_future')
        end
      end
    end
  end
end
