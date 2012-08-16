module Mutant
  class Matcher
    class Method < self
      # Matcher for instance methods
      class Instance < self

        NODE_CLASS = Rubinius::AST::Define

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

        # Return method instance
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          scope.instance_method(method_name)
        end

        # Return matched node
        #
        # @return [Rubinus::AST::Define]
        #
        # @api private
        #
        def matched_node
          last_match = nil
          ast.walk do |predicate, node|
            last_match = node if match?(node)
            predicate
          end
          last_match
        end
      end
    end
  end
end
