require 'spec_helper'

describe Mutant::Runner::Subject do
  let(:object) { described_class }

  let(:config)           { mock('Config')  }
  let(:mutation)         { mock('Mutation') }
  let(:mutation_subject) { [mutation] }

  class DummyRunner
    include Equalizer.new(:config, :mutation)

    attr_reader :mutation

    def initialize(config, mutation)
      @config, @mutation = config, mutation
    end
  end

  before do
    stub_const('Mutant::Runner::Mutation', DummyRunner)
  end

  subject { object.new(config, mutation_subject) }

  its(:mutations) { eql([DummyRunner.new(config, mutation)]) }
end
