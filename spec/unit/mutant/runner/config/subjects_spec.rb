require 'spec_helper'

describe Mutant::Runner::Config, '#subjects' do
  let(:object) { described_class.run(config) }

  subject { object.subjects }

  let(:config)           { mock('Config', :subjects => [mutation_subject]) }
  let(:mutation_subject) { mock('Mutation subject')                        }
  let(:subject_runner)   { mock('Subject runner')                          }

  class DummySubjectRunner
    include Concord.new(:config, :mutation)
    def self.run(*args); new(*args); end
  end

  before do
    stub_const('Mutant::Runner::Subject', DummySubjectRunner)
  end

  it { should eql([DummySubjectRunner.new(config, mutation_subject)]) }

  it_should_behave_like 'an idempotent method'
end
