# frozen_string_literal: true

RSpec.describe Mutant::Result::Mutation do
  let(:object) do
    described_class.new(
      isolation_result: isolation_result,
      mutation:         mutation,
      runtime:          2.0
    )
  end

  let(:mutation) { instance_double(Mutant::Mutation) }

  let(:test_result) do
    instance_double(
      Mutant::Result::Test,
      runtime: 1.0
    )
  end

  let(:isolation_result) do
    Mutant::Isolation::Result.new(
      exception:      nil,
      log:            '',
      process_status: nil,
      timeout:        nil,
      value:          test_result
    )
  end

  describe '#killtime' do
    subject { object.killtime }

    context 'if isolation reports runtime' do
      it { should eql(1.0) }
    end

    context 'if isolation does not report runtime' do
      let(:test_result) { nil }

      it { should eql(0.0) }
    end
  end

  describe '#runtime' do
    subject { object.runtime }

    it { should eql(2.0) }
  end

  describe '#criteria_result' do
    def apply
      object.criteria_result(coverage_criteria)
    end

    let(:coverage_criteria) do
      Mutant::Config::CoverageCriteria::DEFAULT
    end

    before do
      allow(mutation.class).to receive_messages(success?: true)
    end

    context 'when timeouts cover mutations' do
      let(:coverage_criteria) { super().with(timeout: true) }

      context 'on isolation result with timeouts' do
        let(:isolation_result) { super().with(timeout: 1.0) }

        it 'covers timeout' do
          expect(apply.timeout).to be(true)
        end
      end

      context 'on isolation result without timeouts' do
        it 'does not cover timeout' do
          expect(apply.timeout).to be(false)
        end
      end
    end

    context 'when timeouts do not cover mutations' do
      context 'on isolation result with timeouts' do
        let(:isolation_result) { super().with(timeout: 1.0) }

        it 'does not cover timeout' do
          expect(apply.timeout).to be(false)
        end
      end
    end

    context 'when test results cover mutations' do
      context 'on valid isolation result' do
        it 'passes test_results criteria' do
          expect(apply.test_result).to be(true)
        end

        it 'calculates mutation class speific pass state' do
          apply

          expect(mutation.class).to have_received(:success?).with(test_result)
        end
      end

      context 'on invalid isolation results' do
        let(:isolation_result) { super().with(exception: RuntimeError.new) }

        it 'does not pass test_results criteria' do
          expect(apply.test_result).to be(false)
        end
      end
    end

    context 'when test results do not cover mutations' do
      let(:coverage_criteria) { super().with(test_result: false) }

      context 'on valid isolation result' do
        it 'does not pass test_results criteria' do
          expect(apply.test_result).to be(false)
        end
      end
    end
  end
end
