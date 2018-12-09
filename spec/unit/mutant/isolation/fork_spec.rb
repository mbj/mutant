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
  let(:devnull)           { instance_double(Proc, :devnull)             }
  let(:io)                { class_double(IO)                            }
  let(:isolated_block)    { -> { block_return }                         }
  let(:marshal)           { class_double(Marshal)                       }
  let(:process)           { class_double(Process)                       }
  let(:pid)               { class_double(0.class)                       }
  let(:reader)            { instance_double(IO, :reader)                }
  let(:stderr)            { instance_double(IO, :stderr)                }
  let(:stdout)            { instance_double(IO, :stdout)                }
  let(:writer)            { instance_double(IO, :writer)                }
  let(:nullio)            { instance_double(IO, :nullio)                }

  let(:status_success) do
    instance_double(Process::Status, success?: true)
  end

  let(:fork_success) do
    {
      receiver: process,
      selector: :fork,
      reaction: {
        yields: [],
        return: pid
      }
    }
  end

  let(:child_wait) do
    {
      receiver:  process,
      selector:  :wait2,
      arguments: [pid],
      reaction:  {
        return: [pid, status_success]
      }
    }
  end

  let(:writer_close) do
    {
      receiver: writer,
      selector: :close
    }
  end

  let(:load_success) do
    {
      receiver:  marshal,
      selector:  :load,
      arguments: [reader],
      reaction:  {
        return: block_return
      }
    }
  end

  let(:killfork) do
    [
      # Inside the killfork
      {
        receiver: reader,
        selector: :close
      },
      {
        receiver: writer,
        selector: :binmode
      },
      {
        receiver: devnull,
        selector: :call,
        reaction: {
          yields: [nullio]
        }
      },
      {
        receiver:  stderr,
        selector:  :reopen,
        arguments: [nullio]
      },
      {
        receiver:  stdout,
        selector:  :reopen,
        arguments: [nullio]
      },
      {
        receiver:  marshal,
        selector:  :dump,
        arguments: [block_return],
        reaction:  {
          return: block_return_blob
        }
      },
      {
        receiver:  writer,
        selector:  :syswrite,
        arguments: [block_return_blob]
      },
      writer_close
    ]
  end

  describe '#call' do
    let(:object) do
      described_class.new(
        devnull: devnull,
        io:      io,
        marshal: marshal,
        process: process,
        stderr:  stderr,
        stdout:  stdout
      )
    end

    subject { object.call(&isolated_block) }

    let(:prefork_expectations) do
      [
        {
          receiver:  io,
          selector:  :pipe,
          arguments: [binmode: true],
          reaction:  {
            yields: [[reader, writer]]
          }
        }
      ]
    end

    context 'when no IO operation fails' do
      let(:expectations) do
        [
          *prefork_expectations,
          fork_success,
          *killfork,
          writer_close,
          load_success,
          child_wait
        ].map(&XSpec::MessageExpectation.method(:parse))
      end

      specify do
        XSpec::ExpectationVerifier.verify(self, expectations) do
          expect(subject).to eql(Mutant::Isolation::Result::Success.new(block_return))
        end
      end
    end

    context 'when expected exception was raised when reading from child' do
      [ArgumentError, EOFError].each do |exception_class|
        context "on #{exception_class}" do
          let(:exception) { exception_class.new }

          let(:expectations) do
            [
              *prefork_expectations,
              fork_success,
              *killfork,
              {
                receiver: writer,
                selector: :close,
                reaction: {
                  exception: exception
                }
              },
              child_wait
            ].map(&XSpec::MessageExpectation.method(:parse))
          end

          specify do
            XSpec::ExpectationVerifier.verify(self, expectations) do
              expect(subject).to eql(Mutant::Isolation::Result::Exception.new(exception))
            end
          end
        end
      end
    end

    context 'when fork fails' do
      let(:result_class) { described_class::ForkError }

      let(:expectations) do
        [
          *prefork_expectations,
          {
            receiver: process,
            selector: :fork,
            reaction: {
              return: nil
            }
          }
        ].map(&XSpec::MessageExpectation.method(:parse))
      end

      specify do
        XSpec::ExpectationVerifier.verify(self, expectations) do
          expect(subject).to eql(result_class.new)
        end
      end
    end

    context 'when child exits nonzero' do
      let(:status_error) do
        instance_double(Process::Status, success?: false)
      end

      let(:expected_result) do
        Mutant::Isolation::Result::ErrorChain.new(
          described_class::ChildError.new(status_error),
          Mutant::Isolation::Result::Success.new(block_return)
        )
      end

      let(:expectations) do
        [
          *prefork_expectations,
          fork_success,
          *killfork,
          writer_close,
          load_success,
          {
            receiver:  process,
            selector:  :wait2,
            arguments: [pid],
            reaction:  {
              return: [pid, status_error]
            }
          }
        ].map(&XSpec::MessageExpectation.method(:parse))
      end

      specify do
        XSpec::ExpectationVerifier.verify(self, expectations) do
          expect(subject).to eql(expected_result)
        end
      end
    end
  end
end
