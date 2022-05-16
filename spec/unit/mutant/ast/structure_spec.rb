# frozen_string_literal: true

RSpec.describe Mutant::AST::Structure do
  describe '.for' do
    def apply
      described_class.for(type)
    end

    let(:type) { :str }

    it 'returns expected structure' do
      expect(apply).to eql(
        described_class::Node.new(
          type:     :str,
          fixed:    [
            described_class::Node::Fixed::Attribute.new(
              index: 0,
              name:  :value
            )
          ],
          variable: nil
        )
      )
    end
  end
end
