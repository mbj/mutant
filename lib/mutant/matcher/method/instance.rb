module Mutant
  class Matcher
    class Method < self
      # Matcher for instance methods
      class Instance < self

        NODE_CLASS = Rubinius::AST::Define

        def self.extract(constant)
          constant.public_instance_methods(false).map do |name|
            new(constant, name)
          end
        end

      private

        # Return method instance
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          constant.instance_method(method_name)
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
