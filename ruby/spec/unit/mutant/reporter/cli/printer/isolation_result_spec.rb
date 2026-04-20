# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::IsolationResult do
  setup_shared_context

  let(:exception)      { nil }
  let(:log)            { Mutant::LogCapture::String.new(content: '') }
  let(:process_status) { nil                    }
  let(:timeout)        { nil                    }
  let(:value)          { mutation_a_test_result }

  let(:reportable) do
    Mutant::Isolation::Result.new(
      exception:,
      log:,
      process_status:,
      timeout:,
      value:
    )
  end

  describe '.call' do
    context 'on successful isolation' do
      it_reports ''
    end

    context 'on exception isolation error' do
      let(:exception) do
        Mutant::Result::Exception.new(
          backtrace:      %w[first last],
          message:        'Some Exception Message',
          original_class: 'ArgumentError'
        )
      end

      it_reports <<~'STR'
        Killing the mutation resulted in an integration error.
        This is the case when the tests selected for the current mutation
        did not produce a test result, but instead an exception was raised.

        This may point to the following problems:
        * Bug in mutant
        * Bug in the ruby interpreter
        * Bug in your test suite
        * Bug in your test suite under concurrency

        The following exception was raised while reading the killfork result:

        ```
        ArgumentError
        Some Exception Message
        first
        last
        ```
      STR
    end

    context 'with present text log messages' do
      let(:log) { Mutant::LogCapture::String.new(content: "log message\n") }

      it_reports <<~'STR'
        Killfork log (combined stderr and stdout):
        log message
      STR
    end

    context 'with present binary log messages' do
      let(:log) { Mutant::LogCapture::Binary.new(content: "binary \xFF\xFElog\n".b) }

      it 'writes raw bytes to output without raising' do
        described_class.call(output:, object: reportable)
        output.rewind
        expect(output.read.b).to eql("Killfork log (combined stderr and stdout):\nbinary \xFF\xFElog\n".b)
      end
    end

    context 'on unsuccessful process status' do
      let(:process_status) do
        Mutant::Result::ProcessStatus.new(exitstatus: 1)
      end

      it_reports <<~'STR'
        Killfork exited nonzero. Its result (if any) was ignored.
        Process status:
        #<Mutant::Result::ProcessStatus exitstatus=1>
      STR
    end

    context 'on successful process status' do
      let(:process_status) do
        Mutant::Result::ProcessStatus.new(exitstatus: 0)
      end

      it_reports <<~'STR'
        Killfork: #<Mutant::Result::ProcessStatus exitstatus=0>
      STR
    end

    context 'on timeout while process exits successful' do
      let(:process_status) do
        Mutant::Result::ProcessStatus.new(exitstatus: 0)
      end

      let(:timeout) { 2.0 }

      it_reports <<~'STR'
        Mutation analysis ran into the configured timeout of 2 seconds.
        Killfork: #<Mutant::Result::ProcessStatus exitstatus=0>
      STR
    end

    context 'on timeout' do
      let(:timeout) { 1.2 }
      let(:value)   { nil }

      it_reports <<~'STR'
        Mutation analysis ran into the configured timeout of 1.2 seconds.
      STR
    end
  end
end
