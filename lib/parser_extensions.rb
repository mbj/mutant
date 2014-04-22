# Monkeypatch to silence warnings in parser
#
# Will be removed once https://github.com/whitequark/parser/issues/145 is solved.

# Parser namespace
module Parser
  # Monkeypatched lexer
  class Lexer

    # Return new lexer
    #
    # @return [Lexer]
    #
    # @api private
    #
    def self.new(*arguments)
      super.tap do |instance|
        instance.instance_eval do
          @force_utf32 = false
        end
      end
    end

  end # Lexer
end # Parser
