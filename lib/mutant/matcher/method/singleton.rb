module Mutant
  class Matcher
    class Method
      # Matcher for singleton methods
      class Singleton < self
        SUBJECT_CLASS = Subject::Method::Singleton

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

        RECEIVER_INDEX   = 0
        NAME_INDEX       = 1
        CONST_NAME_INDEX = 1

      private

        # Test for node match
        #
        # @param [Parser::AST::Node] node
        #
        # @return [true]
        #   if node matches method
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def match?(node)
          line?(node) && name?(node) && receiver?(node)
        end

        # Test for line match
        #
        # @param [Parser::AST::Node] node
        #
        # @return [true]
        #   if node matches source line
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def line?(node)
          expression = node.location.expression
          return false unless expression
          expression.line == source_line
        end

        # Test for name match
        #
        # @param [Parser::AST::Node] node
        #
        # @return [true]
        #   if node name matches
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def name?(node)
          node.children[NAME_INDEX] == method_name
        end

        # Test for receiver match
        #
        # @param [Parser::AST::Node] node
        #
        # @return [true]
        #   when receiver matches
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def receiver?(node)
          receiver = node.children[RECEIVER_INDEX]
          case receiver.type
          when :self
            true
          when :const
            receiver_name?(receiver)
          else
            $stderr.puts "Can only match self or const, got #{receiver.type}, unable to match receiver of defs node"
            false
          end
        end

        # Test if reciver name matches context
        #
        # @param [Parser::AST::Node] node
        #
        # @return [true]
        #   if node name matches unqualified scope name
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def receiver_name?(node)
          name = node.children[CONST_NAME_INDEX]
          name.to_s == context.unqualified_name
        end

      end # Singleton
    end # Method
  end # Matcher
end # Mutant
