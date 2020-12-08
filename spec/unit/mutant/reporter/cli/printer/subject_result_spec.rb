# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::SubjectResult do
  setup_shared_context

  let(:reportable) { subject_a_result }

  describe '.call' do
    context 'on full coverage' do
      it_reports <<~'STR'
        subject-a
        - test-a
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      it_reports <<~'STR'
        subject-a
        - test-a
        evil:subject-a:d27d2
        -----------------------
        @@ -1 +1 @@
        -true
        +false
        -----------------------
      STR
    end

    context 'without results' do
      with(:subject_a_result) { { coverage_results: [] } }

      it_reports <<~'STR'
        subject-a
        - test-a
      STR
    end
  end
end
