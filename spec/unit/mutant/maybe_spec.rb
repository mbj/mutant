# frozen_string_literal: true

RSpec.describe Mutant::Maybe::Nothing do
  subject { described_class.new }

  let(:block) { -> {} }

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
end

RSpec.describe Mutant::Maybe::Just do
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
    include_examples '#apply block evaluation'
  end
end
