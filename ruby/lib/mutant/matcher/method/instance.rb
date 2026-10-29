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
            if memoized_method?(scope, target_method.name)
              Evaluator::Memoized
            elsif module_function?(scope, target_method)
              Evaluator::ModuleFunction
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
          scope.raw < TARGET_MEMOIZER && scope.raw.memoized?(method_name)
        end
        private_class_method :memoized_method?

        # Test if method was exposed via module_function
        #
        # module_function makes the instance method private and copies it
        # onto the singleton class, where it keeps the source location.
        # Both sides ignore ancestors, so prepended wrappers do not hide the copy.
        #
        # @param [Scope] scope
        # @param [UnboundMethod] target_method
        #
        # @return [Boolean]
        def self.module_function?(scope, target_method)
          raw         = scope.raw
          singleton   = raw.singleton_class
          method_name = target_method.name

          raw.private_method_defined?(method_name, false) &&
            singleton.public_method_defined?(method_name, false) &&
            own_method(singleton.instance_method(method_name), singleton)
              .source_location.eql?(target_method.source_location)
        end
        private_class_method :module_function?

        # Instance method specific evaluator
        class Evaluator < Evaluator
          MATCH_NODE_TYPE = :def
          NAME_INDEX      = 0
          SUBJECT_CLASS   = Subject::Method::Instance

        private

          def match?(node)
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          # Ignore ancestors, as a prepended wrapper can have a different visibility
          def visibility
            if scope.raw.private_method_defined?(method_name, false)
              :private
            elsif scope.raw.protected_method_defined?(method_name, false)
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
                .unmemoized_instance_method(method_name)
                .source_location
            end

          end # Memoized

          # Evaluator specialized for module_function instance methods
          class ModuleFunction < self
            SUBJECT_CLASS = Subject::Method::Instance::ModuleFunction
          end # ModuleFunction
        end # Evaluator

        private_constant(*constants(false))
      end # Instance
    end # Method
  end # Matcher
end # Mutant
