RSpec.describe Mutant::Reporter::CLI::Printer::MutationProgressResult do
  setup_shared_context

  let(:reportable) { mutation_a_result }

  before do
    allow(output).to receive(:tty?).and_return(true)
  end

  describe '.run' do
    context 'on killed mutant' do
      with(:mutation_a_test_result) { { passed: true } }

      it_reports Mutant::Color::RED.format('F')
    end

    context 'on alive mutant' do
      with(:mutation_a_test_result) { { passed: false } }

      it_reports Mutant::Color::GREEN.format('.')
    end
  end
end
