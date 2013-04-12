require 'spec_helper'

describe Mutant::Runner::Subject, '#success?' do
  subject { object.success? }

  let(:object) { described_class.run(config, mutation_subject) }

  let(:mutation_subject) { mock('Subject', :mutations => mutations) }
  let(:config)           { mock('Config')                           }
  let(:mutation_a)       { mock('Mutation A', :fails? => false)     }
  let(:mutation_b)       { mock('Mutation B', :fails? => false)     }
  let(:mutations)        { [mutation_a, mutation_b]                 }

  class DummyMutationRunner
    include Concord.new(:config, :mutation)

    def self.run(*args)
      new(*args)
    end

    def failed?
      @mutation.fails?
    end
  end

  before do
    stub_const('Mutant::Runner::Mutation', DummyMutationRunner)
  end

  context 'without evil failed mutations' do
    it { should be(true) }
  end

  context 'with failing noop mutation' do
  end

  context 'with failing evil mutations' do
    before do
      mutation_a.stub(:fails? => true)
    end

    it { should be(false) }
  end
end
