module Mutant
  # AST helpers
  module AST

    # Walk all ast nodes
    #
    # @param [Parser::AST::Node] root
    # @param [Array<Parser::AST::Node>] stack
    #
    # @yield [Parser::AST::Node]
    #   all nodes recursively including root
    #
    # @return [self]
    #
    # @api private
    #
    def self.walk(node, stack, &block)
      raise ArgumentError, 'block expected' unless block_given?

      block.call(node, stack)
      node.children.grep(Parser::AST::Node).each do |child|
        stack.push(child)
        walk(child, stack, &block)
        stack.pop
      end

      self
    end
    private_class_method :walk

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
    def self.find_last_path(node, &predicate)
      raise ArgumentError, 'block expected' unless block_given?
      path = []
      walk(node, [node]) do |candidate, stack|
        if predicate.call(candidate, &predicate)
          path = stack.dup
        end
      end
      path
    end

  end # AST
end # Mutant
