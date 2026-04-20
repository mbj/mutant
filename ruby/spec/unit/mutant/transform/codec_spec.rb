# frozen_string_literal: true

RSpec.describe Mutant::Transform::Codec do
  let(:dump_transform) do
    Mutant::Transform::Success.new(
      block: ->(object) { { 'value' => object } }
    )
  end

  let(:load_transform) do
    Mutant::Transform::Success.new(
      block: ->(hash) { hash.fetch('value') }
    )
  end

  describe '.for_anima' do
    let(:klass) do
      Class.new do
        include Mutant::Anima.new(:name, :value)
      end
    end

    let(:object) { klass.new(name: 'foo', value: 42) }
    let(:hash)   { { 'name' => 'foo', 'value' => 42 } }
    let(:codec)  { described_class.for_anima(klass) }

    it 'dumps to string-keyed hash' do
      expect(codec.dump(object)).to eql(Mutant::Either::Right.new(hash))
    end

    it 'loads from string-keyed hash' do
      expect(codec.load(hash)).to eql(Mutant::Either::Right.new(object))
    end

    it 'round trips' do
      dumped = codec.dump(object).from_right
      loaded = codec.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end

  describe '#dump' do
    subject { described_class.new(dump_transform:, load_transform:) }

    it 'delegates to dump_transform' do
      result = subject.dump('hello')

      expect(result).to eql(Mutant::Either::Right.new('value' => 'hello'))
    end
  end

  describe '#load' do
    subject { described_class.new(dump_transform:, load_transform:) }

    it 'delegates to load_transform' do
      result = subject.load('value' => 'hello')

      expect(result).to eql(Mutant::Either::Right.new('hello'))
    end
  end
end
