# frozen_string_literal: true

describe Mutant::Mutation::Runner::Sink do
  setup_shared_context

  let(:mutation_a_index_response) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    0,
      log:    '',
      result: mutation_a_index_result
    )
  end

  let(:mutation_b_index_response) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    0,
      log:    '',
      result: mutation_b_index_result
    )
  end

  shared_context 'one result' do
    before do
      object.response(mutation_a_index_response)
    end
  end

  shared_context 'two results' do
    before do
      object.response(mutation_a_index_response)
      object.response(mutation_b_index_response)
    end
  end

  let(:object) { described_class.new(env:) }

  describe '#response' do
    subject { object.response(mutation_a_index_response) }

    context 'on success' do
      it 'aggregates results in #status' do
        subject
        object.response(mutation_b_index_response)
        expect(object.status).to eql(
          Mutant::Result::Env.new(
            env:,
            runtime:         0.0,
            subject_results: [subject_a_result]
          )
        )
      end

      it_should_behave_like 'a command method'
    end

    context 'on error' do
      let(:mutation_a_index_response) { super().with(error: EOFError) }

      it 're-raises the error' do
        expect { subject }.to raise_error(EOFError)
      end
    end
  end

  describe '#status' do
    subject { object.status }

    context 'no results' do
      let(:expected_status) do
        Mutant::Result::Env.new(
          env:,
          runtime:         0.0,
          subject_results: []
        )
      end

      it { should eql(expected_status) }
    end

    context 'one result' do
      include_context 'one result'

      with(:subject_a_result) { { coverage_results: [mutation_a_coverage_result] } }

      let(:expected_status) do
        Mutant::Result::Env.new(
          env:,
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
          env:,
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
