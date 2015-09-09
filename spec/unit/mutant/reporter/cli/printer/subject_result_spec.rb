RSpec.describe Mutant::Reporter::CLI::Printer::SubjectResult do
  setup_shared_context

  let(:reportable) { subject_a_result }

  describe '.call' do
    context 'on full coverage' do
      it_reports <<-'STR'
        subject-a
        - test-a
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_test_result) { { passed: true } }

      it_reports <<-'STR'
        subject-a
        - test-a
        evil:subject-a:d27d2
        @@ -1,2 +1,2 @@
        -true
        +false
        -----------------------
      STR
    end

    context 'without results' do
      with(:subject_a_result) { { mutation_results: [] } }

      it_reports <<-'STR'
        subject-a
        - test-a
      STR
    end
  end
end
