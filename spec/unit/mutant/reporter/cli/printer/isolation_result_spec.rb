# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::IsolationResult do
  setup_shared_context

  let(:exception)      { nil                    }
  let(:log)            { ''                     }
  let(:process_status) { nil                    }
  let(:timeout)        { nil                    }
  let(:value)          { mutation_a_test_result }

  let(:reportable) do
    Mutant::Isolation::Result.new(
      exception:      exception,
      log:            log,
      process_status: process_status,
      timeout:        timeout,
      value:          value
    )
  end

  describe '.call' do
    context 'on successful isolation' do
      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
      STR
    end

    context 'on exception isolation error' do
      let(:exception) do
        Class.new(RuntimeError) do
          def inspect
            '<TestException>'
          end

          def backtrace
            %w[first last]
          end
        end.new('foo')
      end

      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
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
        <TestException>
        first
        last
        ```
      STR
    end

    context 'with present log messages' do
      let(:log) { 'log message' }

      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
        Log messages (combined stderr and stdout):
        [killfork] log message
      STR
    end

    context 'on unsucessful process status' do
      let(:process_status) do
        instance_double(Process::Status, 'unsuccessful status', success?: false)
      end

      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
        Killfork exited nonzero. Its result (if any) was ignored.
        Process status:
        #<InstanceDouble(Process::Status) "unsuccessful status">
      STR
    end

    context 'on successful process status' do
      let(:process_status) do
        instance_double(Process::Status, 'unsuccessful status', success?: true)
      end

      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
      STR
    end

    context 'on timeout while process exits successful' do
      let(:process_status) do
        instance_double(Process::Status, 'unsuccessful status', success?: true)
      end

      let(:timeout) { 2.0 }

      it_reports <<~'STR'
        Mutation analysis ran into the configured timeout of 02 seconds.
        - 1 @ runtime: 1.0
          - test-a
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
