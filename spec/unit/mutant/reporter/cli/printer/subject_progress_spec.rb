# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::SubjectProgress do
  setup_shared_context

  let(:reportable) { subject_a_result }

  describe '.call' do
    context 'on full coverage' do
      it_reports <<~'STR'
        subject-a mutations: 2
        ..
        (02/02) 100% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_test_result) { { passed: true } }

      it_reports <<~'STR'
        subject-a mutations: 2
        F.
        (01/02)  50% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
      STR
    end

    context 'without results' do
      with(:subject_a_result) { { mutation_results: [] } }

      it_reports <<~'STR'
        subject-a mutations: 2
        (00/02) 100% - killtime: 0.00s runtime: 0.00s overhead: 0.00s
      STR
    end
  end
end
