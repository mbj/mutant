module Mutant
  # Mutate rubinius AST nodes
  class Mutator
    include Enumerable, Veritas::Immutable

    # Build mutation node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [Mutator]
    #
    # @api private
    #
    def self.build(node)
      mutator(node).new(node)
    end

    # Return mutator for node or raise
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [Mutator]
    #
    # @raise [ArgumentError]
    #   raises ArgumentError if mutator for node cannot be found
    #
    # @api private
    #
    def self.mutator(node)
      unqualified_name = node.class.name.split('::').last
      const_get(unqualified_name)
    end

    # Enumerate mutated asts
    #
    # @api private
    #
    def each(&block)
      return to_enum unless block_given?
      mutants(Generator.new(@node,block))
      self
    end

  private

    # Return wrapped node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    attr_reader :node

    # Initialize mutator with 
    #
    # @param [Rubinius::AST::Node] node
    #
    # @api private
    #
    def initialize(node)
      @node = node
    end

    # Create a new AST node
    #
    # @param [Rubinis::AST::Node:Class] node_class
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    def new(node_class,*arguments)
      node_class.new(node.line,*arguments)
    end

    # Create a new AST node with same class as wrapped node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    def new_self(*arguments)
      new(node.class,*arguments)
    end

    # Create a new AST node with NilLiteral class
    #
    # @return [Rubinius::AST::NilLiteral]
    #
    # @api private
    #
    def new_nil
      new(Rubinius::AST::NilLiteral)
    end

    # Append mutations
    #
    # @api private
    #
    # @param [#<<] generator
    #
    # @return [undefined]
    #
    def mutants(generator)
      Mutant.not_implemented(self)
    end
  end
end
