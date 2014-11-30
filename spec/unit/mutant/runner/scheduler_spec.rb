require 'spec_helper'

describe Mutant::Runner::Scheduler do
  let(:object) { described_class.new(env) }

  before do
    allow(Time).to receive(:now).and_return(Time.now)
  end

  setup_shared_context

  let(:active_subject_a_result) do
    subject_a_result.update(mutation_results: [])
  end

  describe '#job_result' do
    subject { object.job_result(job_a_result) }

    before do
      expect(object.next_job).to eql(job_a)
    end

    it 'removes the tracking of job as active' do
      expect { subject }.to change { object.status.active_jobs }.from([job_a].to_set).to(Set.new)
    end

    it 'aggregates results in #status' do
      subject
      object.job_result(job_b_result)
      expect(object.status.env_result).to eql(
        Mutant::Result::Env.new(
          env: env,
          runtime: 0.0,
          subject_results: [subject_a_result]
        )
      )
    end

    it_should_behave_like 'a command method'
  end

  describe '#next_job' do
    subject { object.next_job }

    context 'when there is a next job' do
      let(:mutations) { [mutation_a, mutation_b] }

      it { should eql(job_a) }

      it 'does not return the same job again' do
        subject
        expect(object.next_job).to eql(job_b)
        expect(object.next_job).to be(nil)
      end

      it 'does record job as active' do
        expect { subject }.to change { object.status.active_jobs }.from(Set.new).to([job_a].to_set)
      end
    end

    context 'when there is no next job' do
      let(:mutations) { [] }
      it { should be(nil) }
    end
  end

  describe '#status' do
    subject { object.status }

    context 'when empty' do
      let(:expected_status) do
        Mutant::Runner::Status.new(
          env_result:             Mutant::Result::Env.new(env: env, runtime: 0.0, subject_results: []),
          active_jobs:            Set.new,
          done:                   false
        )
      end

      it { should eql(expected_status) }
    end

    context 'when jobs are active' do
      before do
        object.next_job
        object.next_job
      end

      let(:expected_status) do
        Mutant::Runner::Status.new(
          env_result:             Mutant::Result::Env.new(env: env, runtime: 0.0, subject_results: []),
          active_jobs:            [job_a, job_b].to_set,
          done:                   false
        )
      end

      it { should eql(expected_status) }
    end

    context 'remaining jobs are active' do
      before do
        object.next_job
        object.next_job
        object.job_result(job_a_result)
      end

      update(:subject_a_result) { { mutation_results: [mutation_a_result] } }

      let(:expected_status) do
        Mutant::Runner::Status.new(
          env_result:             Mutant::Result::Env.new(env: env, runtime: 0.0, subject_results: [subject_a_result]),
          active_jobs:            [job_b].to_set,
          done:                   false
        )
      end

      it { should eql(expected_status) }
    end

    context 'under fail fast config with failed result' do
      before do
        object.next_job
        object.next_job
        object.job_result(job_a_result)
      end

      update(:subject_a_result)         { { mutation_results: [mutation_a_result] } }
      update(:mutation_a_test_a_result) { { passed:           true                } }
      update(:mutation_a_test_b_result) { { passed:           true                } }
      update(:config)                   { { fail_fast:        true                } }

      let(:expected_status) do
        Mutant::Runner::Status.new(
          env_result:             Mutant::Result::Env.new(env: env, runtime: 0.0, subject_results: [subject_a_result]),
          active_jobs:            [job_b].to_set,
          done:                   true
        )
      end

      it { should eql(expected_status) }
    end

    context 'when done' do
      before do
        object.next_job
        object.next_job
        object.status
        object.job_result(job_a_result)
        object.job_result(job_b_result)
      end

      let(:expected_status) do
        Mutant::Runner::Status.new(
          env_result:             Mutant::Result::Env.new(env: env, runtime: 0.0, subject_results: [subject_a_result]),
          active_jobs:            Set.new,
          done:                   true
        )
      end

      it { should eql(expected_status) }
    end
  end
end
