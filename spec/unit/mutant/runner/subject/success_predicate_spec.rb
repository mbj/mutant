require 'spec_helper'

describe Mutant::Runner::Subject, '#success?' do
  subject { object.success? }

  let(:object) { described_class.run(config, mutation_subject) }

  let(:reporter)         { mock('Reporter')                      }
  let(:mutation_subject) { mock('Subject', :map => mutations)    }
  let(:config)           { mock('Config', :reporter => reporter) }
  let(:mutation_a)       { mock('Mutation A', :failed? => false) }
  let(:mutation_b)       { mock('Mutation B', :failed? => false) }
  let(:mutations)        { [mutation_a, mutation_b]              }

  before do
    reporter.stub(:report => reporter)
  end

  class DummyMutationRunner
    include Concord.new(:config, :mutation)

    def self.run(*args)
      new(*args)
    end

    def failed?
      @mutation.failed?
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
      mutation_a.stub(:failed? => true)
    end

    it { should be(false) }
  end
end
