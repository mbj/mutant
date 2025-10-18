# frozen_string_literal: true

module Mutant
  class AST
    # Node meta information mixin
    module Meta

      # Metadata for symbol nodes
      class Symbol
        include NamedChildren, Anima.new(:node)

        children :name

        public :name

      end # Symbol
    end # Meta
  end # AST
end # Mutant
