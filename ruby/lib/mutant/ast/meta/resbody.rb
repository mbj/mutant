# frozen_string_literal: true

module Mutant
  class AST
    # Node meta information mixin
    module Meta

      # Metadata for resbody nodes
      class Resbody
        include NamedChildren, Anima.new(:node)

        children :captures, :assignment, :body

        public :captures, :assignment, :body
      end # Resbody

    end # Meta
  end # AST
end # Mutant
