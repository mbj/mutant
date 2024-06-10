# frozen_string_literal: true

module Mutant
  class AST
    class Pattern
      # rubocop:disable Metrics/ClassLength
      class Lexer
        WHITESPACE     = [' ', "\t", "\n"].to_set.freeze
        STRING_PATTERN = /\A[a-zA-Z][_a-zA-Z0-9]*\z/

        SINGLE_CHAR =
          {
            '(' => :group_start,
            ')' => :group_end,
            ',' => :delimiter,
            '=' => :eq,
            '{' => :properties_start,
            '}' => :properties_end
          }.freeze

        def self.call(string)
          new(string).__send__(:run)
        end

        class Error
          include Anima.new(:token)

          class InvalidToken < self
            def display_message
              <<~MESSAGE.strip
                Invalid #{token.type} token:
                #{token.display_location}
              MESSAGE
            end
          end # Token
        end # Error

        private_class_method :new

      private

        def initialize(string)
          @line_index    = 0
          @line_start    = 0
          @next_position = 0
          @source        = Source.new(string:)
          @string        = string
          @tokens        = []
        end

        def run
          consume

          if instance_variable_defined?(:@error)
            Either::Left.new(@error)
          else
            Either::Right.new(@tokens)
          end
        end

        def consume
          while next? && !instance_variable_defined?(:@error)
            skip_whitespace

            consume_char || consume_string

            skip_whitespace
          end
        end

        def consume_char
          start_position = @next_position

          char = peek

          type = SINGLE_CHAR.fetch(char) { return }

          advance_position

          @tokens << token(type:, start_position:)
        end

        def token(type:, start_position:, value: nil)
          Token.new(
            type:,
            value:,
            location: Source::Location.new(
              source:     @source,
              line_index: @line_index,
              line_start: @line_start,
              range:      range_from(start_position)
            )
          )
        end

        def consume_string
          start_position = @next_position

          token = build_string(start_position, read_string_body)

          if valid_string?(token.value)
            @tokens << token
          else
            @error = Error::InvalidToken.new(token:)
          end
        end

        def read_string_body
          string = +''

          while next?
            char = peek
            break if SINGLE_CHAR.key?(char) || whitespace?(char)

            string << char
            advance_position
          end

          string
        end

        def build_string(start_position, string)
          token(
            type:           :string,
            value:          string,
            start_position:
          )
        end

        def range_from(start_position)
          start_position...@next_position
        end

        def valid_string?(string)
          STRING_PATTERN.match?(string)
        end

        def advance_position
          @next_position += 1
        end

        def skip_whitespace
          loop do
            char = peek

            break unless whitespace?(char)

            if char.eql?("\n")
              @line_start = @next_position.succ
              @line_index += 1
            end

            advance_position
          end
        end

        def peek
          @string[@next_position]
        end

        def whitespace?(char)
          WHITESPACE.include?(char)
        end

        def next?
          @next_position < @string.length
        end
      end # Lexer
    end # Pattern
  end # AST
end # Mutant
