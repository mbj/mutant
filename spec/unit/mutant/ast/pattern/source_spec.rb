# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Source do
  describe '#line' do
    def apply
      instance.line(line_index)
    end

    let(:string) { "a\n b" }

    let(:instance) do
      described_class.new(string: string)
    end

    context 'on line index 0' do
      let(:line_index) { 0 }

      it 'returns first line' do
        expect(apply).to eql('a')
      end
    end

    context 'on line index 1' do
      let(:line_index) { 1 }

      it 'returns second line' do
        expect(apply).to eql(' b')
      end
    end

    context 'on non unix newline' do
      let(:string) { "a\r\nb" }
      let(:line_index) { 0 }

      it 'considers the \r as part of the previous line' do
        expect(apply).to eql("a\r")
      end
    end
  end
end
