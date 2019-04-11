# frozen_string_literal: true

describe Mutant::Runner::Sink do
  setup_shared_context

  shared_context 'one result' do
    before do
      subject.result(mutation_a_result)
    end
  end

  shared_context 'two results' do
    before do
      subject.result(mutation_a_result)
      subject.result(mutation_b_result)
    end
  end

  let(:reporter) { instance_double(Mutant::Reporter) }

  subject do
    described_class.new(env, reporter)
  end

  before do
    allow(Mutant::Timer).to receive_messages(now: Mutant::Timer.now)
    allow(reporter).to receive_messages(alive: undefined)
  end

  describe '#result' do
    def apply
      subject.result(mutation_a_result)
      subject.result(mutation_b_result)
    end

    it 'returns self' do
      expect(apply).to be(subject)
    end

    it 'aggregates results in #status' do
      apply

      expect(subject.status).to eql(
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: [subject_a_result]
        )
      )
    end
  end

  describe '#status' do
    def apply
      subject.status
    end

    context 'no results' do
      let(:expected_status) do
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: []
        )
      end

      it 'returns expected status' do
        expect(apply).to eql(expected_status)
      end
    end

    context 'one result' do
      include_context 'one result'

      with(:subject_a_result) { { mutation_results: [mutation_a_result] } }

      let(:expected_status) do
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: [subject_a_result]
        )
      end

      it 'returns expected status' do
        expect(apply).to eql(expected_status)
      end
    end

    context 'two results' do
      include_context 'two results'

      let(:expected_status) do
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: [subject_a_result]
        )
      end

      it 'returns expected status' do
        expect(apply).to eql(expected_status)
      end
    end
  end

  describe '#stop?' do
    def apply
      subject.stop?
    end

    context 'without fail fast' do
      context 'no results' do
        it 'returns expected value' do
          expect(apply).to eql(false)
        end
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end
      end
    end

    context 'with fail fast' do
      with(:config) { { fail_fast: true } }

      context 'no results' do
        it 'returns expected value' do
          expect(apply).to eql(false)
        end
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(true)
          end
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it 'returns expected value' do
            expect(apply).to eql(false)
          end
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(true)
          end
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it 'returns expected value' do
            expect(apply).to eql(true)
          end
        end
      end
    end
  end
end
