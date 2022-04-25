# frozen_string_literal: true

RSpec.describe Mutant::Parser do
  let(:object) { described_class.new }

  describe '#call' do
    let(:path) { instance_double(Pathname) }

    let(:expected_node) { s(:sym, :source) }

    subject { object.call(path) }

    let(:buffer) do
      Unparser.buffer(<<~'RUBY')
        :source # comment_a
        :source # comment_b
      RUBY
    end

    let(:expected_associations) do
      associations = {}
      associations.compare_by_identity

      associations[s(:sym, :source)] = [
        Parser::Source::Comment.new(Parser::Source::Range.new(buffer, 8, 19))
      ]

      associations[s(:sym, :source)] = [
        Parser::Source::Comment.new(Parser::Source::Range.new(buffer, 28, 39))
      ]

      associations
    end

    before do
      allow(path).to receive(:read).and_return(buffer.source)
    end

    it 'returns parsed source' do
      expect(subject.inspect).to eql(
        described_class::AST.new(
          comment_associations: expected_associations,
          node:                 s(:begin, expected_node, expected_node)
        ).inspect
      )
    end

    it 'is idempotent' do
      source = object.call(path)
      expect(subject).to be(source)
    end
  end
end
