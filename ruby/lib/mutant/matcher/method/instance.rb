# frozen_string_literal: true

module Mutant
  class Matcher
    class Method
      # Matcher for instance methods
      class Instance < self

        # Dispatching builder, detects memoizable case
        #
        # @param [Scope] scope
        # @param [UnboundMethod] method
        #
        # @return [Matcher::Method::Instance]
        #
        # rubocop:disable Metrics/MethodLength
        def self.new(scope:, target_method:)
          evaluator =
            if memoized_method?(scope.raw, target_method.name)
              Evaluator::Memoized
            else
              Evaluator
            end

          super(
            evaluator:,
            scope:,
            target_method:
          )
        end
        # rubocop:enable Metrics/MethodLength

        TARGET_MEMOIZER = ::Mutant::Adamantium

        private_constant(*constants(false))

        def self.memoized_method?(scope, method_name)
          if scope.singleton_class < ::Memosa && scope.const_defined?(:MemosaMethods)
            ::Memosa::Internal.method_defined?(scope.const_get(:MemosaMethods), method_name)
          end
        end

        # Instance method specific evaluator
        class Evaluator < Evaluator
          MATCH_NODE_TYPE = :def
          NAME_INDEX      = 0
          SUBJECT_CLASS   = Subject::Method::Instance

        private

          def match?(node)
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          def visibility
            if scope.raw.private_method_defined?(method_name)
              :private
            elsif scope.raw.protected_method_defined?(method_name)
              :protected
            else
              :public
            end
          end

          # Evaluator specialized for memoized instance methods
          class Memoized < self
            SUBJECT_CLASS = Subject::Method::Instance::Memoized

          private

            def source_location
              scope
                .raw
                .instance_method(method_name)
                .super_method
                .source_location
            end

          end # Memoized
        end # Evaluator

        private_constant(*constants(false))
      end # Instance
    end # Method
  end # Matcher
end # Mutant
