require 'spec_helper'

describe Mutant::Runner::Subject, '#mutations' do
  let(:object) { described_class.new(config, mutation_subject) }

  subject { object.mutations }

  let(:config)           { mock('Config')  }
  let(:mutation)         { mock('Mutation') }
  let(:mutation_subject) { [mutation] }

  class DummyRunner
    include Composition.new(:config, :mutation)
  end

  before do
    stub_const('Mutant::Runner::Mutation', DummyRunner)
  end

  it { should eql([DummyRunner.new(config, mutation)]) }
end
