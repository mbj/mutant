require 'spec_helper'

describe Mutant::Runner::Subject, '#mutations' do
  let(:object) { described_class.run(config, mutation_subject) }

  subject { object.mutations }

  let(:config)           { mock('Config')   }
  let(:mutation)         { mock('Mutation') }
  let(:mutation_subject) { [mutation] }

  class DummyRunner
    include Concord.new(:config, :mutation)
    def self.run(*args); new(*args); end
  end

  before do
    stub_const('Mutant::Runner::Mutation', DummyRunner)
  end

  it { should eql([DummyRunner.new(config, mutation)]) }

  it_should_behave_like 'an idempotent method'
end
