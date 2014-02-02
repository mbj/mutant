# encoding: utf-8

module Mutant
  class Matcher
    class Method
      # Matcher for instance methods
      class Instance < self
        SUBJECT_CLASS = Subject::Method::Instance

        # Dispatching builder, detects adamantium case
        #
        # @param [Cache] cache
        # @param [Class, Module] scope
        # @param [UnboundMethod] method
        #
        # @return [Matcher::Method::Instance]
        #
        # @api private
        #
        def self.build(cache, scope, method)
          name = method.name
          if scope.ancestors.include?(::Adamantium) and scope.memoized?(name)
            return Memoized.new(cache, scope, method)
          end
          super
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
        memoize :identification

        NAME_INDEX = 0

      private

        # Check if node is matched
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
          location                  = node.location       || return
          expression                = location.expression || return
          expression.line           == source_line &&
          node.type                 == :def        &&
          node.children[NAME_INDEX] == method_name
        end

        # Matcher for memoized instance methods
        class Memoized < self
          SUBJECT_CLASS = Subject::Method::Instance::Memoized

        private

          # Return source location
          #
          # @return [Array]
          #
          # @api private
          #
          def source_location
            scope.unmemoized_instance_method(method.name).source_location
          end

        end # Memoized

      end # Instance
    end # Method
  end # Matcher
end # Mutant
