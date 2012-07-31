module Mutant
  # Represent a mutatable AST and its context
  class Mutatee
    include Veritas::Immutable, Enumerable

    # Return context
    #
    # @return [Context]
    #
    # @api private
    #
    attr_reader :context

    # Return AST node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    attr_reader :node

    # Enumerate possible mutations
    #
    # @return [self]
    #   returns self if block given
    #
    # @return [Enumerator]
    #   returns eumerator if no block given
    #
    # @api private
    #
    def each(&block)
      return to_enum unless block_given?
      Mutator.each(node,&block)

      self
    end

    # Reset implementation to original 
    #
    # This method inserts the original node again. 
    #
    # @return [self]
    #
    # @api private
    # 
    def reset
      insert(@node)

      self
    end

  private 

    # Initialize a mutatee
    #
    # @param [Context] context
    #   the context of mutations
    #
    # @param [Rubinius::AST::Node] node
    #   the node to be mutated
    #
    # @return [unkown]
    #
    # @api private
    #
    def initialize(context,node)
      @context,@node = context,node
    end

    # Insert AST node under context
    #
    # @param [Rubinius::AST::Node] node
    # 
    # @return [self]
    #
    # @api private
    # 
    def insert(node)
      Loader.load(context.root(node))

      self
    end
  end
end
