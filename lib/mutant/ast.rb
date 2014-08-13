module Mutant
  # AST helpers
  module AST

    # Walk all ast nodes
    #
    # @param [Parser::AST::Node]
    #
    # @yield [Parser::AST::Node]
    #   all nodes recursively including root
    #
    # @return [self]
    #
    # @api private
    #
    def self.walk(node, &block)
      raise ArgumentError, 'block expected' unless block_given?

      block.call(node)
      node.children.grep(Parser::AST::Node).each do |child|
        walk(child, &block)
      end

      self
    end

    # Find last node satisfying predicate (as block)
    #
    # @return [Parser::AST::Node]
    #   if satisfying node is found
    #
    # @yield [Parser::AST::Node]
    #
    # @yieldreturn [Boolean]
    #   true in case node satisfies predicate
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.find_last(node, &predicate)
      raise ArgumentError, 'block expected' unless block_given?
      neddle = nil
      walk(node) do |candidate|
        neddle = candidate if predicate.call(candidate, &predicate)
      end
      neddle
    end

  end # AST
end # Mutant
