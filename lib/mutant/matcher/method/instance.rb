module Mutant
  class Matcher
    class Method < Matcher
      # Matcher for instance methods
      class Instance < Method

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

        # Return matched node class
        #
        # @return [Rubinius::AST::Define]
        #
        # @api private
        #
        def node_class
          Rubinius::AST::Define
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
