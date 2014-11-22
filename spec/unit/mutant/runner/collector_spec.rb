require 'spec_helper'

describe Mutant::Runner::Collector do
  let(:object) { described_class.new(env) }

  before do
    allow(Time).to receive(:now).and_return(Time.now)
  end

  let(:env) do
    double(
      'env',
      subjects: [mutation_a.subject]
    )
  end

  let(:mutation_a) do
    double(
      'mutation a',
      subject: double('subject', identification: 'A')
    )
  end

  let(:mutation_a_result) do
    double(
      'mutation a result',
      index:    0,
      runtime:  0.0,
      mutation: mutation_a
    )
  end

  let(:subject_a_result) do
    Mutant::Result::Subject.new(
      subject: mutation_a.subject,
      runtime: 0.0,
      mutation_results: [mutation_a_result]
    )
  end

  let(:active_subject_result) do
    subject_a_result.update(mutation_results: [])
  end

  let(:active_subject_results) do
    [active_subject_result]
  end

  describe '.new' do
    it 'initializes instance variables' do
      expect(object.instance_variables).to include(:@last_mutation_result)
    end
  end

  describe '#start' do
    subject { object.start(mutation_a) }

    it 'tracks the mutation as active' do
      expect { subject }.to change { object.active_subject_results }.from([]).to(active_subject_results)
    end

    it_should_behave_like 'a command method'
  end

  describe '#finish' do
    subject { object.finish(mutation_a_result) }

    before do
      object.start(mutation_a)
    end

    it 'removes the tracking of mutation as active' do
      expect { subject }.to change { object.active_subject_results }.from(active_subject_results).to([])
    end

    it 'sets last mutation result' do
      expect { subject }.to change { object.last_mutation_result }.from(nil).to(mutation_a_result)
    end

    it 'aggregates results in #result' do
      subject
      expect(object.result).to eql(
        Mutant::Result::Env.new(
          env: object.env,
          runtime: 0.0,
          subject_results: [subject_a_result]
        )
      )
    end

    it_should_behave_like 'a command method'
  end

  describe '#last_mutation_result' do
    subject { object.last_mutation_result }

    context 'when empty' do
      it { should be(nil) }
    end

    context 'with partial state' do
      before do
        object.start(mutation_a)
      end

      it { should be(nil) }
    end

    context 'with full state' do
      before do
        object.start(mutation_a)
        object.finish(mutation_a_result)
      end

      it { should be(mutation_a_result) }
    end
  end

  describe '#active_subject_results' do
    subject { object.active_subject_results }

    context 'when empty' do
      it { should eql([]) }
    end

    context 'on partial state' do
      let(:mutation_b) do
        double(
          'mutation b',
          subject: double(
            'subject',
            identification: 'B'
          )
        )
      end

      let(:mutation_b_result) do
        double(
          'mutation b result',
          index:    0,
          runtime:  0.0,
          mutation: mutation_b
        )
      end

      let(:subject_b_result) do
        Mutant::Result::Subject.new(
          subject: mutation_b.subject,
          runtime: 0.0,
          mutation_results: [mutation_b_result]
        )
      end

      let(:active_subject_results) { [subject_a_result, subject_b_result] }

      before do
        object.start(mutation_b)
        object.start(mutation_a)
      end

      it { should eql(active_subject_results.map { |result| result.update(mutation_results: []) }) }
    end

    context 'on full state' do
      before do
        object.start(mutation_a)
        object.finish(mutation_a_result)
      end

      it { should eql([]) }
    end
  end

  describe '#result' do
    subject { object.result }

    context 'when empty' do
      it { should eql(Mutant::Result::Env.new(env: object.env, runtime: 0.0, subject_results: [active_subject_result])) }
    end

    context 'on partial state' do
      before do
        object.start(mutation_a)
      end

      it { should eql(Mutant::Result::Env.new(env: object.env, runtime: 0.0, subject_results: [active_subject_result])) }
    end

    context 'on full state' do
      before do
        object.start(mutation_a)
        object.finish(mutation_a_result)
      end

      it { should eql(Mutant::Result::Env.new(env: object.env, runtime: 0.0, subject_results: [subject_a_result])) }
    end
  end
end
