# frozen_string_literal: true

RSpec.describe Mutant::Result::Env do
  let(:object) do
    described_class.new(
      runtime:         instance_double(Float),
      env:,
      subject_results:
    )
  end

  let(:subject_results) { [subject_result] }

  let(:env) do
    instance_double(
      Mutant::Env,
      config:      instance_double(Mutant::Config, fail_fast:),
      integration:,
      mutations:   [instance_double(Mutant::Mutation)],
      selections:,
      subjects:    [subject_a, subject_b]
    )
  end

  let(:integration) do
    instance_double(
      Mutant::Integration,
      all_tests: [test_a, test_b]
    )
  end

  let(:subject_result) do
    instance_double(
      Mutant::Result::Subject,
      amount_mutation_results: results,
      amount_mutations_killed: killed,
      success?:                subject_success?
    )
  end

  let(:selections) do
    {
      subject_a: [test_a],
      subject_b: [test_a, test_b, test_c]
    }
  end

  let(:subject_a) do
    instance_double(Mutant::Subject, :a)
  end

  let(:subject_b) do
    instance_double(Mutant::Subject, :b)
  end

  let(:test_a) do
    instance_double(Mutant::Test, :a)
  end

  let(:test_b) do
    instance_double(Mutant::Test, :b)
  end

  let(:test_c) do
    instance_double(Mutant::Test, :c)
  end

  let(:fail_fast)        { false }
  let(:killed)           { 0     }
  let(:results)          { 1     }
  let(:subject_success?) { true }

  describe '#success?' do
    subject { object.success? }

    context 'when coverage matches expectation' do
      let(:killed) { 1 }

      it { should be(true) }
    end

    context 'when coverage does not match expectation' do
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

      it { should eql(Rational(1)) }
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

  describe '#stop?' do
    subject { object.stop? }

    context 'without fail fast' do
      context 'on empty subjects' do
        let(:subject_results) { [] }

        it { should be(false) }
      end

      context 'on failed subject' do
        let(:subject_success?) { false }

        it { should be(false) }
      end

      context 'on successful subject' do
        it { should be(false) }
      end
    end

    context 'with fail fast' do
      let(:fail_fast) { true }

      context 'on empty subjects' do
        let(:subject_results) { [] }

        it { should be(false) }
      end

      context 'on failed subject' do
        let(:subject_success?) { false }

        it { should be(true) }
      end

      context 'on successful subject' do
        it { should be(false) }
      end
    end
  end
end
