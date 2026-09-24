# frozen_string_literal: true

RSpec.describe Mutant::Mutation::Runner::Sink do
  setup_shared_context

  let(:mutation_a_index_response) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    0,
      log:    Mutant::LogCapture::String.new(content: ''),
      result: mutation_a_index_result
    )
  end

  let(:mutation_b_index_response) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    0,
      log:    Mutant::LogCapture::String.new(content: ''),
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

  let(:writer) do
    instance_double(Mutant::Result::JSONWriter, call: instance_double(Pathname))
  end

  before do
    allow(Mutant::Result::JSONWriter).to receive(:new).and_return(writer)
  end

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

      it_behaves_like 'a command method'
    end

    context 'on error' do
      let(:mutation_a_index_response) { super().with(error: EOFError) }

      it 're-raises the error' do
        expect { subject }.to raise_error(EOFError)
      end
    end

    context 'session flushing' do
      context 'on an alive mutation' do
        with(:mutation_a_test_result) { { passed: true } }

        it 'flushes the session file' do
          subject

          expect(Mutant::Result::JSONWriter)
            .to have_received(:new).with(env:, result: object.status)
          expect(writer).to have_received(:call)
        end

        context 'followed by another alive mutation' do
          with(:mutation_b_test_result) { { passed: true } }

          # Serializing the result tree is main-process work, so a burst
          # of survivors must not turn into a burst of writes.
          #
          # Timer reads, in order: sink start, first flush check, the
          # status snapshot taken by that flush, second flush check.
          context 'within the flush interval' do
            before do
              allow(timer).to receive(:now).and_return(1.0, 1.0, 1.0, 1.999)
            end

            it 'flushes the session file only once' do
              subject
              object.response(mutation_b_index_response)

              expect(writer).to have_received(:call).once
            end
          end

          context 'after the flush interval' do
            before do
              allow(timer).to receive(:now).and_return(1.0, 1.0, 1.0, 2.0)
            end

            it 'flushes the session file again' do
              subject
              object.response(mutation_b_index_response)

              expect(writer).to have_received(:call).twice
            end
          end
        end
      end

      context 'on a killed mutation' do
        it 'does not flush the session file' do
          subject

          expect(Mutant::Result::JSONWriter).not_to have_received(:new)
        end
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

      it { is_expected.to eql(expected_status) }
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

      it { is_expected.to eql(expected_status) }
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

      it { is_expected.to eql(expected_status) }
    end
  end

  describe '#stop?' do
    subject { object.stop? }

    context 'without fail fast' do
      context 'no results' do
        it { is_expected.to be(false) }
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it { is_expected.to be(false) }
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it { is_expected.to be(false) }
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it { is_expected.to be(false) }
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it { is_expected.to be(false) }
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it { is_expected.to be(false) }
        end
      end
    end

    context 'with fail fast' do
      with(:config) { { fail_fast: true } }

      context 'no results' do
        it { is_expected.to be(false) }
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it { is_expected.to be(false) }
        end

        context 'when result failed' do
          with(:mutation_a_test_result) { { passed: true } }

          it { is_expected.to be(true) }
        end
      end

      context 'two results' do
        include_context 'two results'

        context 'when results are successful' do
          it { is_expected.to be(false) }
        end

        context 'when first result is unsuccessful' do
          with(:mutation_a_test_result) { { passed: true } }

          it { is_expected.to be(true) }
        end

        context 'when second result is unsuccessful' do
          with(:mutation_b_test_result) { { passed: true } }

          it { is_expected.to be(true) }
        end
      end
    end
  end
end
