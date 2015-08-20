module Mutant
  module AST
    # Node meta information mixin
    class Meta
      include NamedChildren, Concord.new(:node)
    end # Meta
  end # AST
end # Mutant
