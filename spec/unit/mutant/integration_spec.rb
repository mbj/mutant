RSpec.describe Mutant::Integration do

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object) { class_under_test.new(Mutant::Config::DEFAULT) }

  describe '#setup' do
    subject { object.setup }
    it_should_behave_like 'a command method'
  end

  describe '.setup' do
    subject { described_class.setup(kernel, name) }

    let(:name)   { 'null'               }
    let(:kernel) { class_double(Kernel) }

    before do
      expect(kernel).to receive(:require)
        .with('mutant/integration/null')
    end

    it { should be(Mutant::Integration::Null) }
  end
end

RSpec.describe Mutant::Integration::Null do

  let(:object) { described_class.new(Mutant::Config::DEFAULT) }

  describe '#all_tests' do
    subject { object.all_tests }

    it { should eql([]) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#call' do
    let(:tests) { instance_double(Array) }

    subject { object.call(tests) }

    it 'returns test result' do
      should eql(
        Mutant::Result::Test.new(
          output:  '',
          passed:  true,
          runtime: 0.0,
          tests:   tests
        )
      )
    end
  end
end
