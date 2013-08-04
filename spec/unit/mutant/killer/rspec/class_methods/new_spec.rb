# encoding: utf-8

require 'spec_helper'

describe Mutant::Killer::Rspec, '.new' do

  before do
    pending 'dactivated'
  end

  subject { object.new(strategy, mutation) }

  let(:context)          { double('Context')          }
  let(:mutation_subject) { double('Mutation Subject') }

  let(:object)  { described_class }

  let(:mutation) do
    double(
      'Mutation',
      :subject => mutation_subject,
      :should_survive? => false
    )
  end

  let(:strategy) do
    double(
      'Strategy',
      :spec_files => ['foo'],
      :error_stream => $stderr,
      :output_stream => $stdout
    )
  end

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
