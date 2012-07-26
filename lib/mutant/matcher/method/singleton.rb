module Mutant
  class Matcher
    class Method
      # Matcher for singleton methods
      class Singleton < Method

      private

        # Return method instance
        # 
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          constant.method(method_name)
        end

        # Return matched node class 
        # 
        # @return [Rubinius::AST::DefineSingletonScope]
        #
        # @api private
        #
        def node_class
          Rubinius::AST::DefineSingletonScope
        end

        # Check for stopping AST walk on branch
        #
        # This method exist to protect against the 
        # artifical edge case where DefineSingleton nodes
        # with differend receivers exist on the same line.
        #
        # @param [Rubnius::AST::Node] node
        #
        # @return [true]
        #   returns true when node should NOT be followed
        #
        # @return [false]
        #   returns false when node can be followed
        #
        # @api private
        #   
        def stop?(node)
          node.is_a?(Rubinius::AST::DefineSingleton) && !match_receiver?(node)
        end

        # Check if receiver matches
        # 
        # @param [Rubinius::AST::DefineSingleton] node
        #
        # @return [true]
        #   returns true when receiver is self or constant from pattern
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match_receiver?(node)
          receiver = node.receiver
          case receiver
          when Rubinius::AST::Self
            true
          when Rubinius::AST::ConstantAccess
            match_receiver_name?(receiver)
          else
            raise 'Can only match receiver on Rubinius::AST::Self or Rubinius::AST::ConstantAccess'
          end
        end

        # Check if reciver name matches context
        #
        # @param [Rubinius::AST::Node] node
        #
        # @return [true]
        #   returns true when node name matches unqualified constant name
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match_receiver_name?(node)
          node.name.to_s == context.unqualified_name
        end

        # Return matched node
        #
        # @return [Rubinus::AST::DefineSingletonScope]
        #
        # @api private
        #
        def matched_node
          last_match = nil
          ast.walk do |predicate, node|
            if match?(node)
              last_match = node
            end
            !stop?(node)
          end
          last_match
        end
      end
    end
  end
end
