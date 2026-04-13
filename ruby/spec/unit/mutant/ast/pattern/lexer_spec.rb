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

  def right(tokens)
    Mutant::Either::Right.new(tokens)
  end

  def string_token(value, range)
    t(
      type:     :string,
      value:    value,
      location: l(range: range, line_index: 0, line_start: 0)
    )
  end

  def bare_token(type, range)
    t(
      type:     type,
      value:    nil,
      location: l(range: range, line_index: 0, line_start: 0)
    )
  end

  context 'empty input' do
    let(:input) { '' }

    let(:expected) do
      right(Mutant::EMPTY_ARRAY)
    end

    include_examples 'lexer call'
  end

  context 'structural tokens' do
    let(:input) { '(){},=' }

    let(:expected) do
      right(
        [
          bare_token(:group_start,      0...1),
          bare_token(:group_end,        1...2),
          bare_token(:properties_start, 2...3),
          bare_token(:properties_end,   3...4),
          bare_token(:delimiter,        4...5),
          bare_token(:eq,               5...6)
        ]
      )
    end

    include_examples 'lexer call'
  end

  context 'whitespace' do
    context 'horizontal' do
      let(:input) { "\t= " }

      let(:expected) do
        right([bare_token(:eq, 1...2)])
      end

      include_examples 'lexer call'
    end

    context 'vertical' do
      let(:input) { "\n =" }

      let(:expected) do
        right(
          [
            t(
              type:     :eq,
              value:    nil,
              location: l(range: 2...3, line_index: 1, line_start: 1)
            )
          ]
        )
      end

      include_examples 'lexer call'
    end
  end

  context 'identifier' do
    context 'terminated by end of input' do
      let(:input) { 'foo' }

      let(:expected) do
        right([string_token('foo', 0...3)])
      end

      include_examples 'lexer call'
    end

    context 'terminated by structural token' do
      let(:input) { 'foo}' }

      let(:expected) do
        right(
          [
            string_token('foo', 0...3),
            bare_token(:properties_end, 3...4)
          ]
        )
      end

      include_examples 'lexer call'
    end

    context 'with bang suffix' do
      let(:input) { 'assert_type!' }

      let(:expected) do
        right([string_token('assert_type!', 0...12)])
      end

      include_examples 'lexer call'
    end

    context 'with query suffix' do
      let(:input) { 'empty?' }

      let(:expected) do
        right([string_token('empty?', 0...6)])
      end

      include_examples 'lexer call'
    end

    context 'with setter suffix' do
      context 'at end of input' do
        let(:input) { 'foo=' }

        let(:expected) do
          right([string_token('foo=', 0...4)])
        end

        include_examples 'lexer call'
      end

      context 'before delimiter' do
        let(:input) { 'foo=,' }

        let(:expected) do
          right(
            [
              string_token('foo=', 0...4),
              bare_token(:delimiter, 4...5)
            ]
          )
        end

        include_examples 'lexer call'
      end

      context 'before group end' do
        let(:input) { 'foo=)' }

        let(:expected) do
          right(
            [
              string_token('foo=', 0...4),
              bare_token(:group_end, 4...5)
            ]
          )
        end

        include_examples 'lexer call'
      end

      context 'before properties end' do
        let(:input) { 'foo=}' }

        let(:expected) do
          right(
            [
              string_token('foo=', 0...4),
              bare_token(:properties_end, 4...5)
            ]
          )
        end

        include_examples 'lexer call'
      end

      context 'before whitespace' do
        let(:input) { 'foo= ' }

        let(:expected) do
          right([string_token('foo=', 0...4)])
        end

        include_examples 'lexer call'
      end
    end

    context 'followed by eq and value' do
      let(:input) { 'foo=bar' }

      let(:expected) do
        right(
          [
            string_token('foo', 0...3),
            bare_token(:eq,     3...4),
            string_token('bar', 4...7)
          ]
        )
      end

      include_examples 'lexer call'
    end
  end

  context 'operator method' do
    def self.operator_example(text)
      context text do
        let(:input) { text }

        let(:expected) do
          right([string_token(text, 0...text.length)])
        end

        include_examples 'lexer call'
      end
    end

    operator_example '=='
    operator_example '==='
    operator_example '=~'
    operator_example '!'
    operator_example '!='
    operator_example '!~'
    operator_example '<'
    operator_example '<='
    operator_example '<=>'
    operator_example '<<'
    operator_example '>'
    operator_example '>='
    operator_example '>>'
    operator_example '+'
    operator_example '+@'
    operator_example '-'
    operator_example '-@'
    operator_example '*'
    operator_example '**'
    operator_example '/'
    operator_example '%'
    operator_example '&'
    operator_example '|'
    operator_example '^'
    operator_example '~'
    operator_example '[]'
    operator_example '[]='

    context 'longest match wins' do
      context 'three char over two char' do
        let(:input) { '<=>' }

        let(:expected) do
          right([string_token('<=>', 0...3)])
        end

        include_examples 'lexer call'
      end

      context 'trailing chars do not extend match' do
        let(:input) { '==a' }

        let(:expected) do
          right(
            [
              string_token('==', 0...2),
              string_token('a',  2...3)
            ]
          )
        end

        include_examples 'lexer call'
      end
    end
  end

  context 'invalid string' do
    context 'terminated by whitespace' do
      let(:input) { 'öö () füü' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: string_token('öö', 0...2)
          )
        )
      end

      include_examples 'lexer call'

      it 'returns expected error message' do
        expect(apply.from_left.display_message).to eql(<<~'MESSAGE'.strip)
          Invalid string token:
          öö () füü
          ^^
        MESSAGE
      end
    end

    context 'terminated by end of input' do
      let(:input) { '@' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: string_token('@', 0...1)
          )
        )
      end

      include_examples 'lexer call'
    end

    context 'following a valid token' do
      let(:input) { 'foo@' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: string_token('@', 3...4)
          )
        )
      end

      include_examples 'lexer call'
    end

    context 'terminated by structural token' do
      let(:input) { '@{' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: string_token('@', 0...1)
          )
        )
      end

      include_examples 'lexer call'
    end

    context 'operator start char with no completing match' do
      let(:input) { '[' }

      let(:expected) do
        Mutant::Either::Left.new(
          described_class::Error::InvalidToken.new(
            token: string_token('[', 0...1)
          )
        )
      end

      include_examples 'lexer call'
    end
  end
end
