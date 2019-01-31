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

  let(:block) { -> {}                            }
  let(:value) { instance_double(Object, 'value') }

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

  describe '#unwrap_error' do
    def apply
      subject.unwrap_error(TestError)
    end

    it 'raises exception' do
      expect { apply }.to raise_error(TestError, value.to_s)
    end
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

  describe '#unwrap_error' do
    let(:exception) { class_double(Exception) }

    def apply
      subject.unwrap_error(exception)
    end

    it 'returns value' do
      expect(apply).to be(value)
    end
  end
end
