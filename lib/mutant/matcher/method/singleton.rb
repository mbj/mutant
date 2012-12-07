module Mutant
  class Matcher
    class Method
      # Matcher for singleton methods
      class Singleton < self

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "#{scope.name}.#{method_name}"
        end
        memoize :identification

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
          scope.singleton_class.public_method_defined?(method_name)
        end


      private

        # Return method instance
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          scope.method(method_name)
        end
        memoize :method, :freezer => :noop

        # Test for node match
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
          node.class == Rubinius::AST::DefineSingleton  &&
          line?(node)                                   && 
          name?(node)                                   && 
          receiver?(node)
        end

        # Test for line match
        #
        # @param [Rubinius::AST::Node] node
        #
        # @return [true]
        #   returns true if node matches source line
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def line?(node)
          node.line  == source_line
        end

        # Test for name match
        #
        # @param [Rubinius::AST::DefineSingleton] node
        #
        # @return [true]
        #   returns true if node name matches
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def name?(node)
          node.body.name == method_name 
        end

        # Test for receiver match
        #
        # @param [Rubinius::AST::DefineSingleton] node
        #
        # @return [true]
        #   returns true when receiver is self or scope from pattern
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def receiver?(node)
          receiver = node.receiver
          case receiver
          when Rubinius::AST::Self
            true
          when Rubinius::AST::ConstantAccess
            receiver_name?(receiver)
          else
            raise 'Can only match receiver on Rubinius::AST::Self or Rubinius::AST::ConstantAccess'
          end
        end

        # Test if reciver name matches context
        #
        # @param [Rubinius::AST::Node] node
        #
        # @return [true]
        #   returns true when node name matches unqualified scope name
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def receiver_name?(node)
          node.name.to_s == context.unqualified_name
        end

      end
    end
  end
end
