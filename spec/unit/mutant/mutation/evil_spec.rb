RSpec.describe Mutant::Mutation::Evil do
  let(:object) do
    described_class.new(mutation_subject, double('node'))
  end

  let(:mutation_subject) { double('subject') }

  describe '.continue?' do
    subject { described_class.continue?(test_results) }

    context 'with empty test results' do
      let(:test_results) { [] }

      it { should be(true) }
    end

    context 'with single passed test result' do
      let(:test_results) { [double('test result', passed: true)] }

      it { should be(true) }
    end

    context 'with failed test result' do
      let(:test_results) { [double('test result', passed: false)] }

      it { should be(false) }
    end

    context 'with passed test result and failed test result' do
      let(:test_results) { [double('test result', passed: true), double('test result', passed: false)] }

      it { should be(false) }
    end
  end

  describe '.success?' do
    subject { described_class.success?(test_results) }

    context 'with empty test results' do
      let(:test_results) { [] }

      it { should be(false) }
    end

    context 'with single passed test result' do
      let(:test_results) { [double('test result', passed: true)] }

      it { should be(false) }
    end

    context 'with failed test result' do
      let(:test_results) { [double('test result', passed: false)] }

      it { should be(true) }
    end

    context 'with passed test result and failed test result' do
      let(:test_results) { [double('test result', passed: true), double('test result', passed: false)] }

      it { should be(true) }
    end
  end
end
