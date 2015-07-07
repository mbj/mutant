module Mutant
  class Matcher
    class Method
      # Matcher for instance methods
      class Instance < self
        SUBJECT_CLASS = Subject::Method::Instance

        # Dispatching builder, detects memoizable case
        #
        # @param [Env::Boostrap] env
        # @param [Class, Module] scope
        # @param [UnboundMethod] method
        #
        # @return [Matcher::Method::Instance]
        #
        # @api private
        def self.build(env, scope, target_method)
          name = target_method.name
          if scope.ancestors.include?(::Memoizable) && scope.memoized?(name)
            return Memoized.new(env, scope, target_method)
          end
          super
        end

        NAME_INDEX = 0

      private

        # Check if node is matched
        #
        # @param [Parser::AST::Node] node
        #
        # @return [Boolean]
        #
        # @api private
        def match?(node)
          location   = node.location       || return
          expression = location.expression || return

          expression.line.equal?(source_line)           &&
          node.type.equal?(:def)                        &&
          node.children[NAME_INDEX].equal?(method_name)
        end

        # Matcher for memoized instance methods
        class Memoized < self
          SUBJECT_CLASS = Subject::Method::Instance::Memoized

        private

          # Source location
          #
          # @return [Array{String,Fixnum}]
          #
          # @api private
          def source_location
            scope.unmemoized_instance_method(method_name).source_location
          end

        end # Memoized

      end # Instance
    end # Method
  end # Matcher
end # Mutant
