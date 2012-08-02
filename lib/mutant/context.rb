module Mutant
  # An abstract context where mutations can be appied to.
  class Context
    include Immutable, Abstract

    # Return root ast for mutated node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [Rubinis::AST::Script]
    #
    # @api private
    #
    abstract_method :root
  end
end
