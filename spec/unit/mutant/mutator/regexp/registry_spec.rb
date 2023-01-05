# frozen_string_literal: true

RSpec.describe Mutant::Mutator::Regexp::Registry, mutant_expression: 'Mutant::Mutator*' do
  describe '.register' do
    let(:object) do
      described_class.new
    end

    let(:expression_class) { Class.new }
    let(:mutator_class_a)  { Class.new }
    let(:mutator_class_b)  { Class.new }

    def apply
      object.register(expression_class, mutator_class_a)
    end

    it 'returns self' do
      expect(apply).to be(object)
    end

    it 'registers single class' do
      apply

      expect(object.lookup(expression_class)).to eql(
        [
          mutator_class_a,
          Mutant::Mutator::Regexp::Quantifier
        ]
      )
    end

    it 'registers multiple classes' do
      object.register(expression_class, mutator_class_b)
      apply

      expect(object.lookup(expression_class)).to eql(
        [
          mutator_class_b,
          mutator_class_a,
          Mutant::Mutator::Regexp::Quantifier
        ]
      )
    end
  end
end
