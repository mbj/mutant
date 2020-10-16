# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example do
  let(:object) do
    described_class.new(
      expected:        mutation_nodes,
      file:            file,
      lvars:           [],
      node:            node,
      original_source: 'true',
      types:           [node.type]
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
end
