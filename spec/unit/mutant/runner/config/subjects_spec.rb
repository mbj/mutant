require 'spec_helper'

describe Mutant::Runner::Config, '#subjects' do
  let(:object) { described_class.run(config) }

  subject { object.subjects }

  let(:config) do
    double(
      'Config',
      :subjects => [mutation_subject],
      :strategy => strategy,
      :reporter => reporter
    )
  end

  let(:reporter)         { double('Reporter')         }
  let(:strategy)         { double('Strategy')         }
  let(:mutation_subject) { double('Mutation subject') }
  let(:subject_runner)   { double('Subject runner')   }

  class DummySubjectRunner
    include Concord::Public.new(:config, :mutation)

    def self.run(*args); new(*args); end
  end

  before do
    strategy.stub(:setup)
    strategy.stub(:teardown)
    reporter.stub(:report => reporter)
    stub_const('Mutant::Runner::Subject', DummySubjectRunner)
  end

  it { should eql([DummySubjectRunner.new(config, mutation_subject)]) }

  it_should_behave_like 'an idempotent method'
end
