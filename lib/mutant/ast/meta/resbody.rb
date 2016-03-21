module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for resbody nodes
      class Resbody
        include NamedChildren, Concord.new(:node)

        children :captures, :assignment, :body

        public :captures, :assignment, :body
      end # Resbody

    end # Meta
  end # AST
end # Mutant
