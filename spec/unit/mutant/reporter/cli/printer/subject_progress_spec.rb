RSpec.describe Mutant::Reporter::CLI::Printer::SubjectProgress do
  setup_shared_context

  let(:reportable) { subject_a_result }

  describe '.call' do
    context 'on full coverage' do
      it_reports <<-'STR'
        subject-a mutations: 2
        ..
        (02/02) 100% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
        - test-a
      STR
    end

    context 'on partial coverage' do
      update(:mutation_a_test_result) { { passed: true } }

      it_reports <<-'STR'
        subject-a mutations: 2
        F.
        (01/02)  50% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
        - test-a
      STR
    end

    context 'without results' do
      update(:subject_a_result) { { mutation_results: [] } }

      it_reports <<-'STR'
        subject-a mutations: 2
        (00/02)   0% - killtime: 0.00s runtime: 0.00s overhead: 0.00s
        - test-a
      STR
    end
  end
end
