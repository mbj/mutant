# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Lexer do
  def apply
    described_class.call(input)
  end

  shared_context 'lexer call' do
    it 'returns expected value' do
      expect(apply).to eql(expected)
    end
  end

  let(:expected_source) do
    Mutant::AST::Pattern::Source.new(string: input)
  end

  def l(**attributes)
    Mutant::AST::Pattern::Source::Location.new(source: expected_source, **attributes)
  end

  def t(**attributes)
    Mutant::AST::Pattern::Token.new(**attributes)
  end

  context 'empty input' do
    let(:input) { '' }

    let(:expected) do
      Mutant::Either::Right.new(Mutant::EMPTY_ARRAY)
    end

    include_examples 'lexer call'
  end

  context 'single char tokens' do
    let(:input) { '(){},=' }

    let(:expected) do
      Mutant::Either::Right.new(
        [
          t(type: :group_start,      value: nil, location: l(range: 0...1, line_index: 0, line_start: 0)),
          t(type: :group_end,        value: nil, location: l(range: 1...2, line_index: 0, line_start: 0)),
          t(type: :properties_start, value: nil, location: l(range: 2...3, line_index: 0, line_start: 0)),
          t(type: :properties_end,   value: nil, location: l(range: 3...4, line_index: 0, line_start: 0)),
          t(type: :delimiter,        value: nil, location: l(range: 4...5, line_index: 0, line_start: 0)),
          t(type: :eq,               value: nil, location: l(range: 5...6, line_index: 0, line_start: 0))
        ]
      )
    end

    include_examples 'lexer call'
  end

  context 'whitespace' do
    context 'horizontal' do
      let(:input) { "\t= " }

      let(:expected) do
        Mutant::Either::Right.new(
          [
            t(type: :eq, value: nil, location: l(range: 1...2, line_index: 0, line_start: 0))
          ]
        )
      end

      include_examples 'lexer call'
    end

    context 'vertical' do
      let(:input) { "\n =" }

      let(:expected) do
        Mutant::Either::Right.new(
          [
            t(type: :eq, value: nil, location: l(range: 2...3, line_index: 1, line_start: 1))
          ]
        )
      end

      include_examples 'lexer call'
    end
  end

  context 'string' do
    context 'valid' do
      context 'terminated by end of input' do
        let(:input) { 'foo' }

        let(:expected) do
          Mutant::Either::Right.new(
            [
              t(type: :string, value: 'foo', location: l(range: 0...3, line_index: 0, line_start: 0))
            ]
          )
        end

        include_examples 'lexer call'
      end

      context 'terminated by other token' do
        let(:input) { 'foo=' }

        let(:expected) do
          Mutant::Either::Right.new(
            [
              t(type: :string, value: 'foo', location: l(range: 0...3, line_index: 0, line_start: 0)),
              t(type: :eq, value: nil, location: l(range: 3...4, line_index: 0, line_start: 0))
            ]
          )
        end

        include_examples 'lexer call'
      end
    end

    context 'invalid' do
      let(:input) { 'föö () füü' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: t(type: :string, value: 'föö', location: l(range: 0...3, line_index: 0, line_start: 0))
          )
        )
      end

      include_examples 'lexer call'

      it 'returns expected error message' do
        expect(apply.from_left.display_message).to eql(<<~'MESSAGE'.strip)
          Invalid string token:
          föö () füü
          ^^^
        MESSAGE
      end
    end
  end
end
