module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for const nodes
      class Const
        include NamedChildren, Concord.new(:node), NodePredicates

        children :base, :name

        # Test if AST node is possibly a top level constant
        #
        # @return [Boolean]
        #
        # @api private
        def possible_top_level?
          base.nil? || n_cbase?(base)
        end

      end # Const
    end # Meta
  end # AST
end # Mutant
