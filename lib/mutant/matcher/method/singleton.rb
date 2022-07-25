# frozen_string_literal: true

module Mutant
  class Matcher
    class Method
      # Matcher for singleton methods
      class Singleton < self

        # New singleton method matcher
        #
        # @param [Class, Module] scope
        # @param [Symbol] method_name
        #
        # @return [Matcher::Method::Singleton]
        def self.new(scope, method_name)
          super(scope, method_name, Evaluator)
        end

        # Singleton method evaluator
        class Evaluator < Evaluator
          MATCH_NODE_TYPE  = :defs
          NAME_INDEX       = 1
          RECEIVER_INDEX   = 0
          RECEIVER_WARNING = 'Can only match :defs on :self or :const got %p unable to match'
          SUBJECT_CLASS    = Subject::Method::Singleton

        private

          def match?(node)
            n_defs?(node) && line?(node) && name?(node) && receiver?(node)
          end

          def line?(node)
            node
              .location
              .line
              .equal?(source_line)
          end

          def name?(node)
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          def receiver?(node)
            receiver = node.children.fetch(RECEIVER_INDEX)
            case receiver.type
            when :self
              true
            when :const
              receiver_name?(receiver)
            else
              env.warn(RECEIVER_WARNING % receiver.type)
              nil
            end
          end

          def receiver_name?(node)
            name = node.children.fetch(NAME_INDEX)
            name.to_s.eql?(context.unqualified_name)
          end

        end # Evaluator

        private_constant(*constants(false))
      end # Singleton
    end # Method
  end # Matcher
end # Mutant
