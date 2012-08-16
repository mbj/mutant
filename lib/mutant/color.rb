module Mutant
  # Class to colorize strings
  class Color
    include Immutable

    def initialize(code)
      @code = code
    end

    def format(text)
      "\e[#{@code}m#{text}\e[0m"
    end

    NONE = Class.new(self) do
      def initialize(*)
      end

      def format(text)
        text
      end
    end.new.freeze

    RED   = Color.new(31)
    GREEN = Color.new(32)
    BLUE  = Color.new(34)
  end
end
