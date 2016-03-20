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
          SUBJECT_CLASS    = Subject::Method::Singleton
          RECEIVER_INDEX   = 0
          NAME_INDEX       = 1
          RECEIVER_WARNING = 'Can only match :defs on :self or :const got %p unable to match'.freeze

        private

          # Test for node match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def match?(node)
            n_defs?(node) && line?(node) && name?(node) && receiver?(node)
          end

          # Test for line match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def line?(node)
            node
              .location
              .line
              .equal?(source_line)
          end

          # Test for name match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def name?(node)
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          # Test for receiver match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
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

          # Test if receiver name matches context
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
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
