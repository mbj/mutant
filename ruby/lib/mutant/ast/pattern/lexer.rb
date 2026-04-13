# frozen_string_literal: true

module Mutant
  class AST
    class Pattern
      # rubocop:disable Metrics/ClassLength
      class Lexer
        WHITESPACE = [' ', "\t", "\n"].to_set.freeze

        STRUCTURAL =
          {
            '(' => :group_start,
            ')' => :group_end,
            ',' => :delimiter,
            '{' => :properties_start,
            '}' => :properties_end
          }.freeze

        EQ_OPERATORS = %w[=== == =~].freeze

        OPERATORS_BY_START =
          {
            '!' => %w[!= !~ !].freeze,
            '<' => %w[<=> << <= <].freeze,
            '>' => %w[>> >= >].freeze,
            '+' => %w[+@ +].freeze,
            '-' => %w[-@ -].freeze,
            '*' => %w[** *].freeze,
            '[' => ['[]=', '[]'].freeze,
            '/' => ['/'].freeze,
            '%' => ['%'].freeze,
            '&' => ['&'].freeze,
            '|' => ['|'].freeze,
            '^' => ['^'].freeze,
            '~' => ['~'].freeze
          }.freeze

        IDENTIFIER_START    = /[a-zA-Z]/
        IDENTIFIER_CONTINUE = /[a-zA-Z0-9_]/

        SETTER_TERMINATORS = (WHITESPACE + [',', ')', '}']).freeze

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
          end # InvalidToken
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
          loop do
            skip_whitespace
            break unless next? && !instance_variable_defined?(:@error)

            consume_structural \
              || consume_eq \
              || consume_operator \
              || consume_identifier \
              || consume_invalid
          end
        end

        def consume_structural
          char = peek
          type = STRUCTURAL.fetch(char) { return }
          start_position = @next_position
          advance_position
          @tokens << token(type:, start_position:)
        end

        def consume_eq
          return unless peek.eql?('=')

          start_position = @next_position

          EQ_OPERATORS.each do |op|
            next unless matches?(op)

            advance_positions(op.length)
            @tokens << token(type: :string, start_position:, value: op)
            return true
          end

          advance_position
          @tokens << token(type: :eq, start_position:)
        end

        def consume_operator
          operators = OPERATORS_BY_START[peek] or return
          match     = operators.detect { |op| matches?(op) } or return

          start_position = @next_position
          advance_positions(match.length)
          @tokens << token(type: :string, start_position:, value: match)
        end

        def consume_identifier
          return unless IDENTIFIER_START.match?(peek)

          start_position = @next_position
          advance_position while IDENTIFIER_CONTINUE.match?(peek)
          consume_identifier_suffix

          @tokens << token(
            type:           :string,
            start_position:,
            value:          @string[range_from(start_position)]
          )
        end

        def consume_identifier_suffix
          advance_position if suffix_char?(peek)
        end

        def suffix_char?(char)
          char.eql?('!') || char.eql?('?') || (char.eql?('=') && setter_suffix_follows?)
        end

        def setter_suffix_follows?
          next_char = @string[@next_position.succ]

          next_char.nil? || SETTER_TERMINATORS.include?(next_char)
        end

        def consume_invalid
          start_position = @next_position
          advance_invalid
          @error = Error::InvalidToken.new(
            token: token(
              type:           :string,
              start_position:,
              value:          @string[range_from(start_position)]
            )
          )
        end

        def advance_invalid
          loop do
            break unless next?
            break if terminates_invalid?(peek)

            advance_position
          end
        end

        def terminates_invalid?(char)
          STRUCTURAL.key?(char) || whitespace?(char)
        end

        def matches?(string)
          @string[@next_position, string.length].eql?(string)
        end

        def advance_positions(count)
          count.times { advance_position }
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

        def range_from(start_position)
          start_position...@next_position
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
      # rubocop:enable Metrics/ClassLength
    end # Pattern
  end # AST
end # Mutant
