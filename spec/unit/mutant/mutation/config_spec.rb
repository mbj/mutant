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

    context 'timeout' do
      let(:key)            { :timeout }
      let(:original_value) { 2        }
      let(:other_value)    { 3        }

      include_examples 'maybe value merge'
    end

    context 'ignore patterns' do
      let(:key)            { :ignore_patterns }
      let(:original_value) { :original        }
      let(:other_value)    { :other           }

      it 'returns other value' do
        expect(apply.ignore_patterns).to be(:other)
      end
    end

    context 'operators' do
      let(:key)            { :operators }
      let(:original_value) { :original  }

      context 'if other value is present' do
        let(:other_value) { :other }

        it 'returns other value' do
          expect(apply.operators).to be(:other)
        end
      end

      context 'if other value is absent' do
        let(:other_value) { nil }

        it 'returns original value' do
          expect(apply.operators).to be(:original)
        end
      end
    end
  end
end
