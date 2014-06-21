require 'spec_helper'

describe Mutant::Mutation do

  class TestMutation < Mutant::Mutation
    SYMBOL = 'test'.freeze
  end

  let(:object)           { TestMutation.new(mutation_subject, Mutant::NodeHelpers::N_NIL)   }
  let(:mutation_subject) { double('Subject', identification: 'subject', source: 'original') }
  let(:node)             { double('Node')                                                   }

  describe '#code' do
    subject { object.code }

    it { should eql('8771a') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#original_source' do
    subject { object.original_source }

    it { should eql('original') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql('nil') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#identification' do

    subject { object.identification }

    it { should eql('test:subject:8771a') }

    it_should_behave_like 'an idempotent method'
  end
end
