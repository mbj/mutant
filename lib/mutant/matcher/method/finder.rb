module Mutant
  class Matcher
    class Method

      # Visitor to find last match inside AST
      class Finder

        # Run finder
        #
        # @param [Parser::AST::Node]
        #
        # @return [Parser::AST::Node]
        #   if found
        #
        # @return [nil]
        #   otherwise
        #
        # @api private
        #
        #
        def self.run(root, &predicate)
          new(root, predicate).match
        end

        private_class_method :new

        # Return match
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        attr_reader :match

      private

        # Initialize object
        #
        # @param [Parer::AST::Node]
        #
        # @return [undefined]
        #
        # @api private
        #
        #
        def initialize(root, predicate)
          @root, @predicate = root, predicate
          visit(root)
        end

        # Visit node
        #
        # @param [Parser::AST::Node] node
        #
        # @return [undefined]
        #
        # @api private
        #
        def visit(node)
          if @predicate.call(node)
            @match = node
          end

          node.children.each do |child|
            visit(child) if child.kind_of?(Parser::AST::Node)
          end
        end

      end # Finder
    end # Method
  end # Matcher
end # Mutant
