RSpec.describe Mutant::Reporter::CLI::Printer::Config do
  setup_shared_context

  let(:reportable) { config }

  describe '.call' do
    context 'on default config' do
      it_reports(<<-REPORT)
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config match_expressions=[] ignore_expressions=[]>
        Integration:     Mutant::Integration::Null
        Expect Coverage: 100.00%
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end

    context 'with non default coverage expectation' do
      update(:config) { { expected_coverage: 0.1r } }

      it_reports(<<-REPORT)
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config match_expressions=[] ignore_expressions=[]>
        Integration:     Mutant::Integration::Null
        Expect Coverage: 10.00%
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end
  end
end
