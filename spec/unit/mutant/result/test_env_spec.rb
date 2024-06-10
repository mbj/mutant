# frozen_string_literal: true

RSpec.describe Mutant::Result::TestEnv do
  let(:object) do
    described_class.new(
      runtime:      instance_double(Float),
      env:,
      test_results:
    )
  end

  let(:env) do
    instance_double(
      Mutant::Env,
      config:      instance_double(Mutant::Config, fail_fast:),
      integration:
    )
  end

  let(:integration) do
    instance_double(
      Mutant::Integration,
      all_tests: [test_a, test_b]
    )
  end

  let(:test_result) do
    Mutant::Result::Test.new(
      job_index: nil,
      output:    '',
      passed:    true,
      runtime:   1.0
    )
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

  let(:fail_fast)    { false }
  let(:test_results) { [test_result] }

  describe '#success?' do
    subject { object.success? }

    context 'when no test failed' do
      it { should be(true) }
    end

    context 'when a test failed' do
      let(:test_result) { super().with(passed: false) }

      it { should be(false) }
    end
  end

  describe '#stop?' do
    subject { object.stop? }

    context 'without fail fast' do
      context 'on empty test results' do
        let(:test_results) { [] }

        it { should be(false) }
      end

      context 'on failed test' do
        let(:test_result) { super().with(passed: false) }

        it { should be(false) }
      end

      context 'on successful subject' do
        it { should be(false) }
      end
    end

    context 'with fail fast' do
      let(:fail_fast) { true }

      context 'on empty tests results' do
        let(:test_results) { [] }

        it { should be(false) }
      end

      context 'on failed subject' do
        let(:test_result) { super().with(passed: false) }

        it { should be(true) }
      end

      context 'on successful tests' do
        it { should be(false) }
      end
    end
  end

  describe '#testttime' do
    def apply
      object.testtime
    end

    context 'on empty test results' do
      let(:test_results) { [] }

      it 'returns 0' do
        expect(apply).to be(0.0)
      end
    end

    context 'on multiple test results' do
      let(:test_results) { [test_result, test_result.with(runtime: 2.2)] }

      it 'returns 0' do
        expect(apply).to be(3.2)
      end
    end
  end

  describe '#amount_test_success' do
    let(:test_results) { [test_result, test_result.with(passed: false)] }

    def apply
      object.amount_tests_success
    end

    it 'returns expected value' do
      expect(apply).to be(1)
    end
  end

  describe '#amount_tests' do
    def apply
      object.amount_tests
    end

    it 'returns expected value' do
      expect(apply).to be(2)
    end
  end

  describe '#amount_test_results' do
    def apply
      object.amount_test_results
    end

    it 'returns expected value' do
      expect(apply).to be(1)
    end
  end
end
