# frozen_string_literal: true

module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for const nodes
      class Const
        include NamedChildren, Concord.new(:node), NodePredicates

        children :base, :name

        public :base, :name

        # Test if AST node is possibly a top level constant
        #
        # @return [Boolean]
        def possible_top_level?
          base.nil? || n_cbase?(base)
        end

      end # Const
    end # Meta
  end # AST
end # Mutant
