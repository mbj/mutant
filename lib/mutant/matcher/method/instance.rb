module Mutant
  class Matcher
    class Method
      # Matcher for instance methods
      class Instance < self
        SUBJECT_CLASS = Subject::Method::Instance

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "#{scope.name}##{method_name}"
        end
        memoize :identification

        NAME_INDEX = 0

      private

        # Check if node is matched
        #
        # @param [Parser::AST::Node] node
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
          location                  = node.location       || return
          expression                = location.expression || return
          expression.line           == source_line &&
          node.type                 == :def        &&
          node.children[NAME_INDEX] == method_name
        end

      end # Instance
    end # Method
  end # Matcher
end # Mutant
