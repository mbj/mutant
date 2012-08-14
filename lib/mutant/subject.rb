module Mutant
  # Subject for mutation wraps AST to mutate with its Context 
  class Subject
    include Immutable, Enumerable

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
    # FIXME:
    #   Rubinus <=> Rspec bug
    #
    #     Mutator.each(node,&block) 
    #
    #   results in rspec expectation mismatch
    #
    def each
      return to_enum unless block_given?
      Mutator.each(node) do |mutant|
        yield mutant
      end

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

  private

    # Initialize subject
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
    def initialize(context, node)
      @context, @node = context, node
    end
  end
end
