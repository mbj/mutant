# frozen_string_literal: true

RSpec.describe Mutant::LogCapture do
  describe '.from_binary' do
    context 'with valid UTF-8 bytes' do
      it 'returns a String subclass' do
        capture = described_class.from_binary(+'hello')

        expect(capture).to eql(Mutant::LogCapture::String.new(content: 'hello'))
      end

      it 'returns UTF-8 encoded content' do
        capture = described_class.from_binary(+'hello')

        expect(capture.content.encoding).to eql(Encoding::UTF_8)
      end

      it 'handles empty input' do
        expect(described_class.from_binary(+'')).to eql(
          Mutant::LogCapture::String.new(content: '')
        )
      end
    end

    context 'with invalid UTF-8 bytes' do
      it 'returns a Binary subclass' do
        capture = described_class.from_binary(+"\xFF\xFE".b)

        expect(capture).to eql(Mutant::LogCapture::Binary.new(content: "\xFF\xFE".b))
      end

      it 'returns ASCII-8BIT encoded content' do
        capture = described_class.from_binary(+"\xFF\xFE".b)

        expect(capture.content.encoding).to eql(Encoding::ASCII_8BIT)
      end
    end
  end

  describe 'CODEC' do
    it 'round trips a String capture' do
      object = Mutant::LogCapture::String.new(content: 'hello')
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips a Binary capture' do
      object = Mutant::LogCapture::Binary.new(content: "\xFF\xFE control".b)
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'dumps String to tagged hash' do
      object = Mutant::LogCapture::String.new(content: 'hello')

      expect(described_class::CODEC.dump(object)).to eql(
        Mutant::Either::Right.new('type' => 'string', 'content' => 'hello')
      )
    end

    it 'dumps Binary to base64 tagged hash' do
      object = Mutant::LogCapture::Binary.new(content: "\xFF\xFE".b)

      expect(described_class::CODEC.dump(object)).to eql(
        Mutant::Either::Right.new('type' => 'binary', 'content' => '//4=')
      )
    end

    it 'returns Left on unknown type' do
      result = described_class::CODEC.load('type' => 'unknown', 'content' => 'x')

      expect(result).to be_a(Mutant::Either::Left)
    end

    context 'backwards compatibility with legacy plain-string log' do
      it 'loads a plain empty string as an empty String capture' do
        expect(described_class::CODEC.load('')).to eql(
          Mutant::Either::Right.new(Mutant::LogCapture::String.new(content: ''))
        )
      end

      it 'loads a plain non-empty string as a String capture' do
        expect(described_class::CODEC.load('legacy log')).to eql(
          Mutant::Either::Right.new(Mutant::LogCapture::String.new(content: 'legacy log'))
        )
      end
    end
  end
end
