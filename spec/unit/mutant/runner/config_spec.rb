require 'spec_helper'

describe Mutant::Runner::Config do
  let(:object) { described_class.run(config) }

  let(:config) do
    Mutant::Config.new(
      matcher:           [subject_a, subject_b],
      debug:             false,
      integration:       integration,
      reporter:          reporter,
      fail_fast:         fail_fast,
      expected_coverage: expected_coverage,
      zombie:            false
    )
  end

  let(:fail_fast)         { false                       }
  let(:expected_coverage) { 100.0                       }
  let(:reporter)          { Mutant::Reporter::Trace.new }
  let(:integration)       { double('Integration')       }
  let(:subject_a)         { double('Subject A')         }
  let(:subject_b)         { double('Subject B')         }

  before do
    integration.stub(:setup)
    integration.stub(:teardown)
    Mutant::Runner.stub(:run).with(config, subject_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, subject_b).and_return(runner_b)
  end

  describe '#subjects' do

    subject { object.subjects }

    let(:runner_a)  { double('Runner A', stop?: stop_a) }
    let(:runner_b)  { double('Runner B', stop?: stop_b) }

    context 'without early stop' do
      let(:stop_a) { false }
      let(:stop_b) { false }

      it { should eql([runner_a, runner_b]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'with early stop' do
      let(:stop_a) { true  }
      let(:stop_b) { false }

      it { should eql([runner_a]) }

      it_should_behave_like 'an idempotent method'
    end
  end

  describe '#coverage' do
    subject { object.coverage }

    let(:runner_a)  { double('Runner A', stop?: false, :mutations => mutations_a) }
    let(:runner_b)  { double('Runner B', stop?: false, :mutations => []) }

    let(:mutations_a) do
      Array.new(amount_mutations) do |number|
        double('Mutation', success?: number <= amount_kills - 1)
      end
    end

    context 'with zero mutations and kills' do
      let(:amount_mutations) { 0 }
      let(:amount_kills)     { 0 }

      it { should eql(0.0) }
    end

    context 'with one mutation' do
      let(:amount_mutations) { 1 }

      context 'and one kill' do
        let(:amount_kills) { 1 }
        it { should eql(100.0) }
      end

      context 'and no kills' do
        let(:amount_kills) { 0 }
        it { should eql(0.0) }
      end
    end

    context 'with many mutations' do
      let(:amount_mutations) { 10 }

      context 'and no kill' do
        let(:amount_kills) { 0 }
        it { should eql(0.0) }
      end

      context 'and some kills' do
        let(:amount_kills) { 2 }
        it { should eql(20.0) }
      end

      context 'and as many kills' do
        let(:amount_kills) { amount_mutations }
        it { should eql(100.0) }
      end
    end
  end

  describe '#success?' do
    subject { object.success? }

    let(:mutation_a) do
      double('Mutation A', success?: false)
    end

    let(:mutation_b) do
      double('Mutation B', success?: true)
    end

    let(:runner_a) do
      double('Runner A', stop?: false, success?: false, mutations: [mutation_a])
    end

    let(:runner_b) do
      double('Runner B', stop?: false, success?: true, mutations: [mutation_b])
    end

    let(:runner_a) do
      double('Runner A', stop?: false, success?: false, mutations: [mutation_a])
    end

    let(:runner_b) do
      double('Runner B', stop?: false, success?: true, mutations: [mutation_b])
    end

    context 'without fail fast' do

      context 'when expected coverage equals actual coverage' do
        let(:expected_coverage) { 50.0 }
        it { should be(true) }
      end

      context 'when expected coverage closely equals actual coverage' do
        let(:expected_coverage) { 50.01 }
        it { should be(true) }
      end

      context 'when expected coverage does not equal actual coverage' do
        let(:expected_coverage) { 51.00 }
        it { should be(false) }
      end

    end
  end
end
