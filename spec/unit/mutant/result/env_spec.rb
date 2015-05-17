RSpec.describe Mutant::Result::Env do
  let(:object) do
    described_class.new(
      runtime:         double('Runtime'),
      env:             env,
      subject_results: [subject_result]
    )
  end

  let(:env) do
    double(
      'Env',
      config:    config,
      subjects:  [double('Subject')],
      mutations: [double('Mutation')]
    )
  end

  let(:config) do
    double(
      'Config',
      expected_coverage: expected
    )
  end

  let(:subject_result) do
    double(
      'Subject Result',
      amount_mutation_results: results,
      amount_mutations_killed: killed,
      success?:                true
    )
  end

  let(:expected) { Rational(1) }
  let(:results)  { 9           }
  let(:killed)   { 0           }

  describe '#success?' do
    subject { object.success? }

    context 'when coverage matches expectation exactly' do
      let(:killed) { 9 }

      it { should be(true) }
    end

    context 'when coverage matches expectation approximately' do
      let(:expected) { Rational('0.8888') }
      let(:killed)   { 8                  }

      it { should be(true) }
    end

    context 'when coverage does not match expectation' do
      let(:killed) { 8 }

      it { should be(false) }
    end
  end

  describe '#failed_subject_results' do
    subject { object.failed_subject_results }

    it { should eql([]) }
  end

  describe '#coverage' do
    subject { object.coverage }

    context 'when there are no results' do
      let(:results) { 0 }

      it { should eql(Rational(0)) }
    end

    context 'when there are no kills' do
      it { should eql(Rational(0)) }
    end

    context 'when there are kills' do
      let(:killed)  { 1 }
      let(:results) { 2 }

      it { should eql(Rational(1, 2)) }
    end
  end

  describe '#amount_mutations' do
    subject { object.amount_mutations }

    it { should eql(1) }
  end

  describe '#amount_subjects' do
    subject { object.amount_subjects }

    it { should eql(1) }
  end
end
