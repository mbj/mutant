# frozen_string_literal: true

RSpec.describe Mutant::Result::Mutation do
  let(:object) do
    described_class.new(
      isolation_result:,
      mutation:,
      runtime:          2.0
    )
  end

  let(:mutation)                { instance_double(Mutant::Mutation) }
  let(:process_status_success?) { true                              }

  let(:test_result) do
    instance_double(
      Mutant::Result::Test,
      runtime: 1.0
    )
  end

  let(:process_status) do
    instance_double(
      Process::Status,
      success?: process_status_success?
    )
  end

  let(:isolation_result) do
    Mutant::Isolation::Result.new(
      exception:      nil,
      log:            '',
      process_status:,
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
      Mutant::Config::CoverageCriteria::DEFAULT.with(timeout: false)
    end

    before do
      allow(mutation.class).to receive_messages(success?: true)
    end

    context 'when process aborts cover mutations' do
      let(:coverage_criteria) { super().with(process_abort: true) }

      context 'without process status' do
        let(:isolation_result) { super().with(process_status: nil) }

        it 'does not cover process_abort' do
          expect(apply.process_abort).to be(false)
        end
      end

      context 'and process status indicates abnormal exit' do
        let(:process_status_success?) { false }

        context 'on isolation result with timeout' do
          let(:isolation_result) { super().with(timeout: 1.0) }

          it 'does not cover process_abort' do
            expect(apply.process_abort).to be(false)
          end
        end

        context 'on isolation result without timeout' do
          it 'does not cover process_abort' do
            expect(apply.process_abort).to be(true)
          end
        end
      end

      context 'and process status indicates normal exit' do
        it 'does not cover process_abort' do
          expect(apply.process_abort).to be(false)
        end
      end
    end

    context 'when process aborts do not cover mutations' do
      let(:coverage_criteria) { super().with(process_abort: false) }

      context 'and process status indicates abnormal exit' do
        let(:process_status_success?) { false }

        it 'covers process_abort' do
          expect(apply.process_abort).to be(false)
        end
      end

      context 'and process status indicates normal exit' do
        it 'covers process_abort' do
          expect(apply.process_abort).to be(false)
        end
      end
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
