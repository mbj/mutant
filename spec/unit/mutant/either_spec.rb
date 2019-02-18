# frozen_string_literal: true

RSpec.describe Mutant::Either do
  describe '.wrap_error' do
    def apply
      described_class.wrap_error(error, &block)
    end

    let(:error) { TestError }

    class TestError < RuntimeError; end

    context 'when block returns' do
      let(:value) { instance_double(Object, 'value') }
      let(:block) { -> { value }                     }

      it 'returns right wrapping block value' do
        expect(apply).to eql(described_class::Right.new(value))
      end
    end

    context 'when block raises' do
      let(:exception) { error.new             }
      let(:block)     { -> { fail exception } }

      context 'with covered exception' do
        it 'returns left wrapping exception' do
          expect(apply).to eql(described_class::Left.new(exception))
        end
      end

      context 'with uncovered exception' do
        let(:exception) { StandardError.new }

        it 'returns raises error' do
          expect { apply }.to raise_error(StandardError)
        end
      end
    end
  end
end

RSpec.describe Mutant::Either::Left do
  subject { described_class.new(value) }

  let(:block_result) { instance_double(Object, 'block result') }
  let(:value)        { instance_double(Object, 'value')        }
  let(:yields)       { []                                      }

  let(:block) do
    lambda do |value|
      yields << value
      block_result
    end
  end

  class TestError < RuntimeError; end

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end

  describe '#apply' do
    def apply
      subject.apply(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end

  describe '#from_right' do
    def apply
      subject.from_right(&block)
    end

    context 'without block' do
      let(:block) { nil }

      it 'raises RuntimeError error' do
        expect { apply }.to raise_error(
          RuntimeError,
          "Expected right value, got #{subject.inspect}"
        )
      end
    end

    context 'with block' do
      let(:yields)       { []                                      }
      let(:block_return) { instance_double(Object, 'block-return') }

      let(:block) do
        lambda do |value|
          yields << value
          block_return
        end
      end

      it 'calls block with left value' do
        expect { apply }.to change(yields, :to_a).from([]).to([value])
      end

      it 'returns block value' do
        expect(apply).to be(block_return)
      end
    end
  end

  describe '#lmap' do
    def apply
      subject.lmap(&block)
    end

    include_examples 'requires block'
    include_examples 'Functor#fmap block evaluation'
  end

  describe '#either' do
    def apply
      subject.either(block, -> { fail })
    end

    include_examples 'Applicative#apply block evaluation'
  end
end

RSpec.describe Mutant::Either::Right do
  subject { described_class.new(value) }

  let(:block_result) { instance_double(Object, 'block result') }
  let(:value)        { instance_double(Object, 'value')        }
  let(:yields)       { []                                      }

  let(:block) do
    lambda do |value|
      yields << value
      block_result
    end
  end

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'requires block'
    include_examples 'Functor#fmap block evaluation'
  end

  describe '#apply' do
    def apply
      subject.apply(&block)
    end

    include_examples 'requires block'
    include_examples 'Applicative#apply block evaluation'
  end

  describe '#from_right' do
    def apply
      subject.from_right(&block)
    end

    it 'returns right value' do
      expect(apply).to be(value)
    end

    include_examples 'no block evaluation'
  end

  describe '#lmap' do
    def apply
      subject.lmap(&block)
    end

    include_examples 'requires block'
    include_examples 'no block evaluation'

    it 'returns self' do
      expect(apply).to be(subject)
    end
  end

  describe '#either' do
    def apply
      subject.either(-> { fail }, block)
    end

    include_examples 'Applicative#apply block evaluation'
  end
end
