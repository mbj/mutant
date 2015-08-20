module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for resbody nods
      class Resbody
        include NamedChildren, Concord.new(:node)

        children :captures, :assignment, :body
      end # Resbody

    end # Meta
  end # AST
end # Mutant
