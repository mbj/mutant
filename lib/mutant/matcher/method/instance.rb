module Mutant
  class Matcher
    class Method
      # Matcher for instance methods
      class Instance < self

        # Dispatching builder, detects memoizable case
        #
        # @param [Class, Module] scope
        # @param [UnboundMethod] method
        #
        # @return [Matcher::Method::Instance]
        def self.new(scope, target_method)
          name = target_method.name
          evaluator =
            if scope.include?(Memoizable) && scope.memoized?(name)
              Evaluator::Memoized
            else
              Evaluator
            end

          super(scope, target_method, evaluator)
        end

        # Instance method specific evaluator
        class Evaluator < Evaluator
          SUBJECT_CLASS = Subject::Method::Instance
          NAME_INDEX    = 0

        private

          # Check if node is matched
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def match?(node)
            n_def?(node)                           &&
            node.location.line.equal?(source_line) &&
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          # Evaluator specialized for memoized instance methods
          class Memoized < self
            SUBJECT_CLASS = Subject::Method::Instance::Memoized

          private

            # Source location
            #
            # @return [Array{String,Integer}]
            def source_location
              scope
                .unmemoized_instance_method(method_name)
                .source_location
            end

          end # Memoized
        end # Evaluator

        private_constant(*constants(false))
      end # Instance
    end # Method
  end # Matcher
end # Mutant
