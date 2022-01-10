# frozen_string_literal: true

RSpec.describe Mutant::Expression::Descendants do
  let(:object) { parse_expression(input)    }
  let(:input)  { 'descendants:TestApp::Foo' }

  describe '#matcher' do
    def apply
      object.matcher
    end

    it 'returns expected matcher' do
      expect(apply).to eql(Mutant::Matcher::Descendants.new(const_name: 'TestApp::Foo'))
    end
  end

  describe '#syntax' do
    def apply
      object.syntax
    end

    it 'returns input' do
      expect(apply).to eql(input)
    end
  end

  describe '.try_parse' do
    def apply
      described_class.try_parse(input)
    end

    context 'on valid input' do
      it 'returns expected matcher' do
        expect(apply).to eql(described_class.new(const_name: 'TestApp::Foo'))
      end
    end

    context 'on invalid input' do
      let(:input) { '' }

      it 'returns nil' do
        expect(apply).to be(nil)
      end
    end
  end
end
