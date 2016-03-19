RSpec.describe Mutant::Meta::Example do
  let(:object) do
    described_class.new(
      file:      file,
      node:      node,
      node_type: node.type,
      expected:  mutation_nodes
    )
  end

  let(:file)           { 'foo/bar.rb'         }
  let(:node)           { s(:true)             }
  let(:mutation_nodes) { [s(:nil), s(:false)] }

  let(:mutations) do
    mutation_nodes.map do |node|
      Mutant::Mutation::Evil.new(object, node)
    end
  end

  describe '#source' do
    subject { object.source }

    it { should eql('true') }
  end

  describe '#verification' do
    subject { object.verification }

    it { should eql(Mutant::Meta::Example::Verification.new(object, mutations)) }
  end
end
