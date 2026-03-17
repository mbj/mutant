# frozen_string_literal: true

RSpec.describe Mutant::Transform::JSON do
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

  describe '.build' do
    def apply
      described_class.build(dump: dump_transform, load: load_transform)
    end

    it 'returns a JSON instance' do
      expect(apply).to be_a(described_class)
    end

    describe 'dump' do
      it 'returns JSON string' do
        result = apply.dump('hello')

        expect(result).to eql(Mutant::Either::Right.new('{"value":"hello"}'))
      end
    end

    describe 'load' do
      it 'returns parsed object' do
        result = apply.load('{"value":"hello"}')

        expect(result).to eql(Mutant::Either::Right.new('hello'))
      end

      context 'on invalid JSON' do
        it 'returns error' do
          result = apply.load('not json')

          expect(result).to be_a(Mutant::Either::Left)
        end
      end
    end

    describe 'round trip' do
      it 'round trips through JSON string' do
        json = apply
        input = 'test_value'

        dumped = json.dump(input).from_right
        loaded = json.load(dumped).from_right

        expect(loaded).to eql(input)
      end
    end
  end

  describe '.for_anima' do
    let(:klass) do
      Class.new do
        include Mutant::Anima.new(:name, :value)
      end
    end

    let(:object)  { klass.new(name: 'foo', value: 42) }
    let(:hash)    { { 'name' => 'foo', 'value' => 42 } }
    let(:json)    { described_class.for_anima(klass) }

    it 'dumps to string-keyed hash' do
      expect(json.dump(object)).to eql(Mutant::Either::Right.new(hash))
    end

    it 'loads from string-keyed hash' do
      expect(json.load(hash)).to eql(Mutant::Either::Right.new(object))
    end

    it 'round trips' do
      dumped = json.dump(object).from_right
      loaded = json.load(dumped).from_right

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
