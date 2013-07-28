require 'spec_helper'

describe Mutant::Runner::Subject, '#success?' do
  subject { object.success? }

  let(:object) { described_class.new(config, mutation_subject) }

  let(:mutation_subject) do
    double(
      'Subject',
      :class     => Mutant::Subject,
      :mutations => [mutation_a, mutation_b]
    )
  end

  let(:reporter)   { double('Reporter')                      }
  let(:config)     { double('Config', :reporter => reporter) }
  let(:mutation_a) { double('Mutation A')                    }
  let(:mutation_b) { double('Mutation B')                    }

  let(:runner_a) do
    double('Runner A', :success? => success_a, :stop? => stop_a)
  end

  let(:runner_b) do
    double('Runner B', :success? => success_b, :stop? => stop_b)
  end

  before do
    reporter.stub(:report => reporter)
    Mutant::Runner.stub(:run).with(config, mutation_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, mutation_b).and_return(runner_b)
  end

  context 'with failing mutations' do
    let(:stop_a)    { false }
    let(:stop_b)    { false }
    let(:success_a) { false }
    let(:success_b) { true  }

    it { should be(false) }

    it_should_behave_like 'an idempotent method'
  end

  context 'without failing mutations' do
    let(:stop_a)    { false }
    let(:stop_b)    { false }
    let(:success_a) { true  }
    let(:success_b) { true  }

    it { should be(true) }

    it_should_behave_like 'an idempotent method'
  end
end
