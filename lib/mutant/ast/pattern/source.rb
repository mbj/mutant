# frozen_string_literal: true

module Mutant
  module AST
    class Pattern
      class Source
        include Anima.new(:string)

        def initialize(**attributes)
          super

          @lines = string.split("\n")
        end

        def line(line_index)
          @lines.fetch(line_index)
        end

        class Location
          include Anima.new(:source, :range, :line_index, :line_start)

          def display
            "#{source.line(line_index)}\n#{prefix}#{carets}"
          end

        private

          def prefix
            ' ' * (range.begin - line_start)
          end

          def carets
            '^' * range.size
          end
        end
      end # Source
    end # Pattern
  end # AST
end # Mutant
