module Mutant
  class Matcher
    class Method
      # Matcher for singleton methods
      class Singleton < self

        # Return matcher enumerable
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Matcher::Method::Singleton>]
        #
        # @api private
        #
        def self.each(scope)
          return to_enum unless block_given?
          scope.singleton_class.public_instance_methods(false).reject do |method|
            method.to_sym == :__class_init__
          end.each do |name|
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
          "#{scope.name}.#{method_name}"
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
          node.class == Rubinius::AST::DefineSingleton  &&
          node.body.name  == method_name && match_receiver?(node)
        end

        # Check if receiver matches
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
        #   returns true when node name matches unqualified scope name
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match_receiver_name?(node)
          node.name.to_s == context.unqualified_name
        end

      end
    end
  end
end
