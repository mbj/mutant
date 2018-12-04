# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::IsolationResult do
  setup_shared_context

  describe '.call' do
    context 'on failed isolation' do
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

      let(:reportable) do
        Mutant::Isolation::Result::Error.new(exception)
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

        The following exception was raised:

        ```
        <TestException>
        first
        last
        ```
      STR
    end

    context 'on sucessful isolation' do
      let(:reportable) do
        Mutant::Isolation::Result::Success.new(mutation_a_test_result)
      end

      it_reports <<~'STR'
        - 1 @ runtime: 1.0
          - test-a
        Test Output:
        mutation a test result output
      STR
    end
  end
end
