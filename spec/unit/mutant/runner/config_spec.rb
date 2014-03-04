# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Config do

  let(:config) do
    Mutant::Config.new(
      matcher:           [subject_a, subject_b],
      cache:             Mutant::Cache.new,
      debug:             false,
      strategy:          strategy,
      reporter:          reporter,
      fail_fast:         fail_fast,
      expected_coverage: expected_coverage,
      zombie:            false
    )
  end

  let(:fail_fast)         { false }
  let(:expected_coverage) { 100.0 }

  before do
    reporter.stub(report: reporter)
    strategy.stub(:setup)
    strategy.stub(:teardown)
    Mutant::Runner.stub(:run).with(config, subject_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, subject_b).and_return(runner_b)
  end

  let(:reporter) { double('Reporter') }
  let(:strategy) { double('Strategy') }
  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }

  describe '#subjects' do
    let(:object) { described_class.run(config) }

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

  describe '#success?' do
    subject { object.success? }

    let(:object) { described_class.new(config) }

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
