# frozen_string_literal: true

RSpec.describe Mutant do
  describe '.traverse' do
    def apply
      described_class.traverse(action, values)
    end

    let(:values) { [1, 2, 3] }

    context 'all evalauting to right' do
      let(:action) { ->(value) { right(value.to_s) } }
      let(:values) { [1, 2, 3] }

      it 'returns values' do
        expect(apply)
          .to eql(right(values.map(&:to_s)))
      end
    end

    context 'some evalauting to left' do

      let(:action) do
        lambda do |value|
          if value.equal?(2)
            left(2)
          else
            right(value)
          end
        end
      end

      it 'returns first left value' do
        expect(apply).to eql(left(2))
      end
    end
  end
end
