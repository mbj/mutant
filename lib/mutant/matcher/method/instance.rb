module Mutant
  class Matcher
    class Method < self
      # Matcher for instance methods
      class Instance < self


        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "#{scope.name}##{method_name}"
        end

        # Test if method is public
        #
        # @return [true]
        #   if method is public
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def public?
          scope.public_method_defined?(method_name)
        end
        memoize :public?

      private

        # Check if node is matched
        #
        # @param [Rubinius::AST::Node] node
        #
        # @return [true]
        #   returns true if node matches method
        #
        # @return [false]
        #   returns false if node NOT matches method
        #
        # @api private
        #
        def match?(node)
          node.line  == source_line &&
          node.class == Rubinius::AST::Define  &&
          node.name  == method_name
        end

      end
    end
  end
end
