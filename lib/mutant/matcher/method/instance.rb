module Mutant
  class Matcher
    class Method < self
      # Matcher for instance methods
      class Instance < self

        # Extract instance method matchers from scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Matcher::Method::Instance>]
        #
        # @api private
        #
        def self.each(scope)
          return to_enum unless block_given?
          return unless scope.kind_of?(Module)
          scope.public_instance_methods(false).map do |name|
            yield new(scope, name)
          end
        end

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "#{scope.name}##{method_name}"
        end

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

        # Return method instance
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          scope.instance_method(method_name)
        end

      end
    end
  end
end
