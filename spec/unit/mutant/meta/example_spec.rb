# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example do
  let(:object) do
    described_class.new(
      expected:        mutation_nodes,
      location:        location,
      lvars:           [],
      node:            node,
      original_source: 'true',
      types:           [node.type]
    )
  end

  let(:location) do
    instance_double(
      Thread::Backtrace::Location,
      path: 'foo/bar.rb',
      to_s: '<location>'
    )
  end

  let(:file)           { 'foo/bar.rb' }
  let(:node)           { s(:true)     }
  let(:mutation_nodes) { [s(:false)]  }

  let(:mutations) do
    mutation_nodes.map do |node|
      Mutant::Mutation::Evil.new(object, node)
    end
  end

  describe '#original_source_generated' do
    subject { object.original_source_generated }

    it { should eql('true') }
  end

  describe '#verification' do
    subject { object.verification }

    it { should eql(Mutant::Meta::Example::Verification.new(object, mutations)) }
  end

  describe '#context' do
    subject { object.context }

    it { should eql(Mutant::Context.new(Object, location.path)) }
  end

  describe '#identification' do
    subject { object.identification }

    it { should eql('<location>') }
  end
end
