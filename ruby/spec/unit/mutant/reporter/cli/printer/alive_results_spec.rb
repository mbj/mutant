# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::AliveResults do
  setup_shared_context

  let(:host_class) do
    Class.new(Mutant::Reporter::CLI::Printer) do
      include Mutant::Reporter::CLI::Printer::AliveResults

      def run
        print_alive_results(object)
      end
    end
  end

  def apply
    host_class.call(output:, object: failed_subject_results)
    output.rewind
    output.read
  end

  describe '#print_alive_results' do
    context 'with failed subjects' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      let(:failed_subject_results) { [subject_a_result] }

      it 'prints subject results', mutant_expression: 'Mutant::Reporter::CLI::Printer.call' do
        expect(apply).to eql(<<~'STR')
          subject-a
          tests: 1, runtime: 2.00s, killtime: 2.00s
          evil:subject-a:d27d2
          -----------------------
          @@ -1 +1 @@
          -true
          +false
          -----------------------
          selected tests (1):
          - test-a
        STR
      end
    end

    context 'with verbose display config' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      with(:mutation_a_isolation_result) do
        {
          process_status: Mutant::Result::ProcessStatus.new(exitstatus: 0)
        }
      end

      let(:failed_subject_results) { [subject_a_result] }

      it 'passes display_config to SubjectResult' do
        host_class.call(
          display_config: Mutant::Reporter::CLI::Printer::DisplayConfig::VERBOSE,
          output:,
          object:         failed_subject_results
        )
        output.rewind

        expect(output.read).to include('Killfork: #<Mutant::Result::ProcessStatus exitstatus=0>')
      end
    end

    context 'with empty subjects' do
      let(:failed_subject_results) { [] }

      it 'prints nothing' do
        expect(apply).to eql('')
      end
    end
  end
end
