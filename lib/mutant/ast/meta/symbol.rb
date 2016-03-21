module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for symbol nodes
      class Symbol
        include NamedChildren, Concord.new(:node)

        children :name

        public :name

      end # Symbol
    end # Meta
  end # AST
end # Mutant
