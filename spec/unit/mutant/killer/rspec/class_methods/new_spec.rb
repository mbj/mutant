require 'spec_helper'

describe Mutant::Killer::Rspec, '.new' do

  subject { object.new(strategy, mutation) }

  let(:strategy)         { double('Strategy', :spec_files => ['foo'], :error_stream => $stderr, :output_stream => $stdout) }
  let(:context)          { double('Context')                                                                               }
  let(:mutation)         { double('Mutation', :subject => mutation_subject, :should_survive? => false)                     }
  let(:mutation_subject) { double('Mutation Subject')                                                                      }

  let(:object)  { described_class }

  before do
    mutation.stub(:insert)
    mutation.stub(:reset)
    RSpec::Core::Runner.stub(:run => exit_status)
  end

  context 'when run exits zero' do
    let(:exit_status) { 0 }

    its(:killed?) { should be(false) }

    it { should be_a(described_class) }
  end

  context 'when run exits nonzero' do
    let(:exit_status) { 1 }

    its(:killed?) { should be(true) }

    it { should be_a(described_class) }
  end
end
