# frozen_string_literal: true

RSpec.describe Mutant::Mutation::Config do
  describe '#merge' do
    def apply
      original.merge(other)
    end

    def expect_value(value)
      expect(apply).to eql(original.with(key => value))
    end

    let(:original) do
      described_class::DEFAULT.with(key => original_value)
    end

    let(:other) do
      described_class::DEFAULT.with(key => other_value)
    end

    context 'merging timeout' do
      let(:key)            { :timeout }
      let(:original_value) { 2        }
      let(:other_value)    { 3        }

      include_examples 'maybe value merge'
    end
  end
end
