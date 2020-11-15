# frozen_string_literal: true

describe Mutant::Runner::Sink do
  setup_shared_context

  shared_context 'one result' do
    before do
      object.result(mutation_a_result)
    end
  end

  shared_context 'two results' do
    before do
      object.result(mutation_a_result)
      object.result(mutation_b_result)
    end
  end

  let(:object) { described_class.new(env) }

  describe '#result' do
    subject { object.result(mutation_a_result) }

    it 'aggregates results in #status' do
      subject
      object.result(mutation_b_result)
      expect(object.status).to eql(
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: [subject_a_result]
        )
      )
    end

    it_should_behave_like 'a command method'
  end

  describe '#status' do
    subject { object.status }

    context 'no results' do
      let(:expected_status) do
        Mutant::Result::Env.new(
          env:             env,
          runtime:         0.0,
          subject_results: []
        )
      end

      it { should eql(expected_status) }
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

      it { should eql(expected_status) }
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

      it { should eql(expected_status) }
    end
  end

  describe '#stop?' do
    subject { object.stop? }

    context 'without fail fast' do
      context 'no results' do
        it { should be(false) }
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it { should be(false) }
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it { should be(false) }
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it { should be(false) }
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it { should be(false) }
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it { should be(false) }
        end
      end
    end

    context 'with fail fast' do
      with(:config) { { fail_fast: true } }

      context 'no results' do
        it { should be(false) }
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it { should be(false) }
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it { should be(true) }
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it { should be(false) }
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it { should be(true) }
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it { should be(true) }
        end
      end
    end
  end
end
