# frozen_string_literal: true

module Mutant
  module AST
    class Pattern
      class Token
        include Anima.new(:type, :value, :location)

        def display_location
          location.display
        end
      end # Token
    end # Pattern
  end # AST
end # Mutant
