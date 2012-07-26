module Mutant
  # Mutate rubinius AST nodes
  class Mutator
    # Initialize mutator
    #
    # @param [Rubinius::AST::Node] node
    #
    # @api private
    #
    def initialize(node)
      @node = node
    end

#   # Enumerate mutated asts
#   #
#   # @api private
#   #
#   def each
#     return to_enum(__method__) unless block_given?
#     self
#   end
  end
end
