# frozen_string_literal: true

# The fork isolation is all about managing a series of systemcalls with proper error handling
#
# So creating a unit spec for this is challenging. Especially under mutation testing.
# Hence we even have to implement our own message expectation mechanism, as rspec build in
# expectations are not able to correctly specify a sequence of expectations where a specific
# message is send twice.
#
# Also our replacement for rspec-expectations used here allows easier deduplication.
RSpec.describe Mutant::Isolation::Fork do
  let(:block_return)      { instance_double(Object, :block_return)      }
  let(:block_return_blob) { instance_double(String, :block_return_blob) }
  let(:isolated_block)    { -> { block_return }                         }
  let(:log_fragment)      { 'log message'                               }
  let(:log_reader)        { instance_double(IO, :log_reader)            }
  let(:log_writer)        { instance_double(IO, :log_writer)            }
  let(:pid)               { class_double(Integer)                       }
  let(:read_bytes)        { 4096                                        }
  let(:result_fragment)   { 'result body'                               }
  let(:result_reader)     { instance_double(IO, :result_reader)         }
  let(:result_writer)     { instance_double(IO, :result_writer)         }
  let(:timeout)           { nil                                         }

  let(:child_status_success) do
    instance_double(Process::Status, :success, success?: true)
  end

  let(:child_status_error) do
    instance_double(Process::Status, :error, success?: false)
  end

  let(:world) { fake_world }

  let(:fork_success) do
    {
      receiver: world.process,
      selector: :fork,
      reaction: {
        yields: [],
        return: pid
      }
    }
  end

  def child_nowait(status)
    child_wait(status, Process::WNOHANG)
  end

  def child_wait(status, *arguments)
    {
      receiver:  world.process,
      selector:  :wait2,
      arguments: [pid, *arguments],
      reaction:  {
        return: status && [pid, status]
      }
    }
  end

  def close(descriptor)
    {
      receiver: descriptor,
      selector: :close
    }
  end

  def sleep
    {
      receiver:  world.kernel,
      selector:  :sleep,
      arguments: [0.1]
    }
  end

  def read(io, result)
    {
      receiver:  io,
      selector:  :read_nonblock,
      arguments: [read_bytes, { exception: false }],
      reaction:  { return: result }
    }
  end

  def eof(io, result)
    {
      receiver: io,
      selector: :eof?,
      reaction: { return: result }
    }
  end

  def select(waiting, result, timeout = nil)
    {
      receiver:  world.io,
      selector:  :select,
      arguments: [waiting, [], [], timeout],
      reaction:  { return: [result, [], []] }
    }
  end

  def kill
    {
      receiver:  world.process,
      selector:  :kill,
      arguments: ['KILL', pid]
    }
  end

  let(:load_success) do
    {
      receiver:  world.marshal,
      selector:  :load,
      arguments: [result_fragment],
      reaction:  {
        return: block_return
      }
    }
  end

  let(:read_fragments) do
    [
      select([log_reader, result_reader], [log_reader, result_reader]),
      eof(log_reader, false),
      read(log_reader, log_fragment),
      eof(result_reader, false),
      read(result_reader, result_fragment),
      select([log_reader, result_reader], [log_reader, result_reader]),
      eof(log_reader, true),
      eof(result_reader, true)
    ]
  end

  let(:killfork) do
    [
      {
        receiver: log_reader,
        selector: :close
      },
      {
        receiver: result_reader,
        selector: :close
      },
      {
        receiver:  world.stderr,
        selector:  :reopen,
        arguments: [log_writer]
      },
      {
        receiver:  world.stdout,
        selector:  :reopen,
        arguments: [log_writer]
      },
      {
        receiver:  world.marshal,
        selector:  :dump,
        arguments: [block_return],
        reaction:  { return: block_return_blob }
      },
      {
        receiver:  result_writer,
        selector:  :syswrite,
        arguments: [block_return_blob]
      },
      close(result_writer),
      close(log_writer)
    ]
  end

  describe '#call' do
    subject { described_class.new(world: world) }

    def apply
      subject.call(timeout, &isolated_block)
    end

    let(:prefork_expectations) do
      [
        {
          receiver:  world.io,
          selector:  :pipe,
          arguments: [binmode: true],
          reaction:  {
            yields: [[result_reader, result_writer]]
          }
        },
        {
          receiver:  world.io,
          selector:  :pipe,
          arguments: [binmode: true],
          reaction:  {
            yields: [[log_reader, log_writer]]
          }
        }
      ]
    end

    context 'without configured timeouts' do
      let(:raw_expectations) do
        [
          *prefork_expectations,
          fork_success,
          *killfork,
          close(result_writer),
          *read_fragments,
          load_success,
          child_nowait(child_status_success)
        ]
      end

      context 'read results in wait error' do
        let(:read_fragments) do
          [
            select([log_reader, result_reader], [log_reader, result_reader]),
            eof(log_reader, false),
            read(log_reader, :wait_readable),
            eof(result_reader, false),
            read(result_reader, result_fragment),
            select([log_reader, result_reader], [log_reader, result_reader]),
            eof(log_reader, true),
            eof(result_reader, true)
          ]
        end

        it 'returns success result' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            '',
                exception:      nil,
                process_status: child_status_success,
                timeout:        nil,
                value:          block_return
              )
            )
          end
        end
      end

      context 'multiple reads' do
        let(:full_fragment) { '_' * read_bytes }

        let(:read_fragments) do
          [
            select([log_reader, result_reader], [log_reader, result_reader]),
            eof(log_reader, false),
            read(log_reader, full_fragment),
            read(log_reader, log_fragment),
            eof(result_reader, false),
            read(result_reader, result_fragment),
            select([log_reader, result_reader], [log_reader, result_reader]),
            eof(log_reader, true),
            eof(result_reader, true)
          ]
        end

        it 'returns success result' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            full_fragment + log_fragment,
                exception:      nil,
                process_status: child_status_success,
                timeout:        nil,
                value:          block_return
              )
            )
          end
        end
      end

      context 'happy path' do
        it 'returns success result' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            log_fragment,
                exception:      nil,
                process_status: child_status_success,
                timeout:        nil,
                value:          block_return
              )
            )
          end
        end
      end
    end

    def timer(now)
      {
        receiver: world.timer,
        selector: :now,
        reaction: { return: now }
      }
    end

    context 'with configured timeouts' do
      let(:timeout) { 4.0 }

      let(:prefork_expectations) do
        [timer(0.0), *super()]
      end

      context 'reads within timeout' do
        let(:read_fragments) do
          [
            timer(1.0),
            select([log_reader, result_reader], [log_reader, result_reader], 3.0),
            eof(log_reader, false),
            read(log_reader, log_fragment),
            eof(result_reader, false),
            read(result_reader, result_fragment),
            timer(2.0),
            select([log_reader, result_reader], [log_reader, result_reader], 2.0),
            eof(log_reader, true),
            eof(result_reader, true)
          ]
        end

        let(:raw_expectations) do
          [
            *prefork_expectations,
            fork_success,
            *killfork,
            close(result_writer),
            *read_fragments,
            load_success,
            *post_reads
          ]
        end

        context 'when child terminates immediately' do
          let(:post_reads) { [child_nowait(child_status_success)] }

          it 'returns success result' do
            verify_events do
              expect(apply).to eql(
                described_class::Result.new(
                  log:            log_fragment,
                  exception:      nil,
                  process_status: child_status_success,
                  timeout:        nil,
                  value:          block_return
                )
              )
            end
          end
        end

        context 'child does not terminate immediately' do
          context 'but still within timeout' do
            let(:post_reads) do
              [
                child_nowait(nil),
                timer(3.0),
                sleep,
                child_nowait(nil),
                timer(3.1),
                sleep,
                child_nowait(child_status_success)
              ]
            end

            it 'returns success' do
              verify_events do
                expect(apply).to eql(
                  described_class::Result.new(
                    log:            log_fragment,
                    exception:      nil,
                    process_status: child_status_success,
                    timeout:        nil,
                    value:          block_return
                  )
                )
              end
            end
          end

          context 'and does not within timeout' do
            let(:post_reads) do
              [
                child_nowait(nil),
                timer(4.0),
                kill,
                child_wait(child_status_error)
              ]
            end

            it 'returns success' do
              verify_events do
                expect(apply).to eql(
                  described_class::Result.new(
                    log:            log_fragment,
                    exception:      nil,
                    process_status: child_status_error,
                    timeout:        nil,
                    value:          block_return
                  )
                )
              end
            end
          end
        end
      end

      context 'timeout from select' do
        let(:read_fragments) do
          [
            timer(1.0),
            select([log_reader, result_reader], nil, 3.0)
          ]
        end

        let(:raw_expectations) do
          [
            *prefork_expectations,
            fork_success,
            *killfork,
            close(result_writer),
            *read_fragments,
            kill,
            child_wait(child_status_success)
          ]
        end

        it 'returns result indicating timeout' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            '',
                exception:      nil,
                process_status: child_status_success,
                timeout:        4.0,
                value:          nil
              )
            )
          end
        end
      end

      context 'timeout outside select' do
        let(:read_fragments) do
          [
            timer(5.0)
          ]
        end

        let(:raw_expectations) do
          [
            *prefork_expectations,
            fork_success,
            *killfork,
            close(result_writer),
            *read_fragments,
            kill,
            child_wait(child_status_success)
          ]
        end

        it 'returns timeout result' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            '',
                exception:      nil,
                process_status: child_status_success,
                timeout:        4.0,
                value:          nil
              )
            )
          end
        end
      end
    end

    context 'when expected exception was raised when loading result' do
      let(:exception) { ArgumentError.new }

      let(:raw_expectations) do
        [
          *prefork_expectations,
          fork_success,
          *killfork,
          close(result_writer),
          *read_fragments,
          {
            receiver:  world.marshal,
            selector:  :load,
            arguments: [result_fragment],
            reaction:  {
              exception: exception
            }
          },
          child_nowait(child_status_success)
        ]
      end

      it 'returns exception result' do
        verify_events do
          expect(apply).to eql(
            described_class::Result.new(
              log:            log_fragment,
              exception:      Mutant::Isolation::Exception.new(
                backtrace:      exception.backtrace,
                message:        exception.message,
                original_class: exception.class
              ),
              process_status: child_status_success,
              timeout:        nil,
              value:          nil
            )
          )
        end
      end
    end

    context 'when child does not terminate immediately' do
      context 'while terminating within deadline' do
        let(:raw_expectations) do
          [
            *prefork_expectations,
            fork_success,
            *killfork,
            close(result_writer),
            *read_fragments,
            load_success,
            child_nowait(nil),
            sleep,
            child_nowait(child_status_success)
          ]
        end

        it 'returns success' do
          verify_events do
            expect(apply).to eql(
              described_class::Result.new(
                log:            log_fragment,
                exception:      nil,
                process_status: child_status_success,
                timeout:        nil,
                value:          block_return
              )
            )
          end
        end
      end
    end

    context 'when child exits nonzero' do
      let(:raw_expectations) do
        [
          *prefork_expectations,
          fork_success,
          *killfork,
          close(result_writer),
          *read_fragments,
          load_success,
          child_nowait(child_status_error)
        ]
      end

      it 'returns expected error chain' do
        verify_events do
          expect(apply).to eql(
            described_class::Result.new(
              log:            log_fragment,
              exception:      nil,
              process_status: child_status_error,
              timeout:        nil,
              value:          block_return
            )
          )
        end
      end
    end
  end
end
