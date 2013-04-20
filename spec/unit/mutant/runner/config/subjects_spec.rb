require 'spec_helper'

describe Mutant::Runner::Config, '#subjects' do
  let(:object) { described_class.run(config) }

  subject { object.subjects }

  let(:config)           { mock('Config', :subjects => [mutation_subject], :strategy => strategy) }
  let(:strategy)         { mock('Strategy')                                                       }
  let(:mutation_subject) { mock('Mutation subject')                                               }
  let(:subject_runner)   { mock('Subject runner')                                                 }

  class DummySubjectRunner
    include Concord.new(:config, :mutation)

    def self.run(*args); new(*args); end
  end

  before do
    strategy.stub(:setup)
    strategy.stub(:teardown)
    stub_const('Mutant::Runner::Subject', DummySubjectRunner)
  end

  it { should eql([DummySubjectRunner.new(object, mutation_subject)]) }

  it_should_behave_like 'an idempotent method'
end
