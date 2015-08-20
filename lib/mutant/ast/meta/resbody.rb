module Mutant
  module AST
    # Node meta information mixin
    class Meta

      # Metadata for resbody nods
      class Resbody < self
        children :captures, :assignment, :body
      end # Resbody

    end # Meta
  end # AST
end # Mutant
