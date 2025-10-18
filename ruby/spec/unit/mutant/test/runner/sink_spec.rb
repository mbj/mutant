# frozen_string_literal: true

describe Mutant::Test::Runner::Sink do
  let(:object)    { described_class.new(env:) }
  let(:fail_fast) { false }

  let(:env) do
    instance_double(
      Mutant::Env,
      config:,
      world:  instance_double(
        Mutant::World,
        timer:,
        stderr:
      )
    )
  end

  let(:stderr) do
    instance_double(IO, :stderr)
  end

  let(:config) do
    instance_double(Mutant::Config, fail_fast:)
  end

  let(:timer) do
    instance_double(Mutant::Timer)
  end

  let(:test_result_a_raw) do
    Mutant::Result::Test.new(
      job_index: nil,
      output:    '',
      passed:    true,
      runtime:   0.1
    )
  end

  let(:test_result_b_raw) do
    Mutant::Result::Test.new(
      job_index: nil,
      output:    '',
      passed:    true,
      runtime:   0.2
    )
  end

  let(:job_a) do
    Mutant::Parallel::Source::Job.new(
      index:   0,
      payload: nil
    )
  end

  let(:job_b) do
    Mutant::Parallel::Source::Job.new(
      index:   1,
      payload: nil
    )
  end

  let(:test_result_a) { test_result_a_raw.with(job_index: 0, output: test_response_a.log) }
  let(:test_result_b) { test_result_b_raw.with(job_index: 1, output: test_response_b.log) }

  let(:test_response_a) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    job_a,
      result: test_result_a_raw,
      log:    '<test-a>'
    )
  end

  let(:test_response_b) do
    Mutant::Parallel::Response.new(
      error:  nil,
      job:    job_b,
      result: test_result_b_raw,
      log:    '<test-b>'
    )
  end

  before do
    allow(timer).to receive(:now).and_return(0.5, 2.0)
  end

  shared_context 'one result' do
    before do
      object.response(test_response_a)
    end
  end

  shared_context 'two results, in job index order' do
    before do
      object.response(test_response_a)
      object.response(test_response_b)
    end
  end

  describe '#response' do
    subject { object.response(test_response_a) }

    context 'on success' do
      it 'aggregates results in #status' do
        subject
        object.response(test_response_b)
        expect(object.status).to eql(
          Mutant::Result::TestEnv.new(
            env:,
            runtime:      1.5,
            test_results: [test_result_a, test_result_b]
          )
        )
      end

      it_should_behave_like 'a command method'
    end

    context 'on error' do
      before do
        allow(stderr).to receive(:puts)
      end

      it 'aggregates results in #status' do
        subject

        expect do
          object.response(
            Mutant::Parallel::Response.new(
              error:  EOFError,
              job:    0,
              log:    'some log',
              result: nil
            )
          )
        end.to raise_error(EOFError)

        expect(stderr).to have_received(:puts).with('some log')
      end

      it_should_behave_like 'a command method'
    end
  end

  describe '#status' do
    subject { object.status }

    context 'no results' do
      let(:expected_status) do
        Mutant::Result::TestEnv.new(
          env:,
          runtime:      1.5,
          test_results: []
        )
      end

      it { should eql(expected_status) }
    end

    context 'one result' do
      include_context 'one result'

      let(:expected_status) do
        Mutant::Result::TestEnv.new(
          env:,
          runtime:      1.5,
          test_results: [test_result_a]
        )
      end

      it { should eql(expected_status) }
    end

    context 'two results, in job index order' do
      include_context 'two results, in job index order'

      let(:expected_status) do
        Mutant::Result::TestEnv.new(
          env:,
          runtime:      1.5,
          test_results: [test_result_a, test_result_b]
        )
      end

      it { should eql(expected_status) }
    end

    context 'two results, not in job index order' do
      before do
        object.response(test_response_b)
        object.response(test_response_a)
      end

      let(:expected_status) do
        Mutant::Result::TestEnv.new(
          env:,
          runtime:      1.5,
          test_results: [test_result_a, test_result_b]
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
          it { should be(false) }
        end
      end

      context 'two results, in job index order' do
        include_context 'two results, in job index order'

        context 'when results are successful' do
          it { should be(false) }
        end

        context 'when first result is unsuccessful' do
          it { should be(false) }
        end

        context 'when second result is unsuccessful' do
          it { should be(false) }
        end
      end
    end

    context 'with fail fast' do
      let(:fail_fast) { true }

      context 'no results' do
        it { should be(false) }
      end

      context 'one result' do
        include_context 'one result'

        context 'when result is successful' do
          it { should be(false) }
        end

        context 'when result failed' do
          let(:test_result_a_raw) { super().with(passed: false) }

          it { should be(true) }
        end
      end

      context 'two results, in job index order' do
        include_context 'two results, in job index order'

        context 'when results are successful' do
          it { should be(false) }
        end

        context 'when first result is unsuccessful' do
          let(:test_result_a_raw) { super().with(passed: false) }

          it { should be(true) }
        end

        context 'when second result is unsuccessful' do
          let(:test_result_b_raw) { super().with(passed: false) }

          it { should be(true) }
        end
      end
    end
  end
end
