# frozen_string_literal: true

module Mutant
  class AST
    # Node meta information mixin
    module Meta

      # Metadata for send nodes
      class Send
        include NamedChildren, Concord.new(:node), NodePredicates

        children :receiver, :selector

        public :receiver, :selector

        ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX = '='

        # Arguments of mutated node
        #
        # @return [Enumerable<Parser::AST::Node>]
        alias_method :arguments, :remaining_children

        public :arguments

        # Test if node is defining a proc
        #
        # @return [Boolean]
        def proc?
          naked_proc? || proc_new?
        end

        # Test if AST node is a valid attribute assignment
        #
        # @return [Boolean]
        def attribute_assignment?
          !Types::METHOD_OPERATORS.include?(selector) &&
          selector.to_s.end_with?(ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX)
        end

        # Test for binary operator implemented as method
        #
        # @return [Boolean]
        def binary_method_operator?
          Types::BINARY_METHOD_OPERATORS.include?(selector)
        end

        # Test if receiver is possibly a top level constant
        #
        # @return [Boolean]
        def receiver_possible_top_level_const?
          return false unless receiver && n_const?(receiver)

          Const.new(receiver).possible_top_level?
        end

      private

        def naked_proc?
          !receiver && selector.equal?(:proc)
        end

        def proc_new?
          receiver                &&
            selector.equal?(:new) &&
            n_const?(receiver)    &&
            Const.new(receiver).name.equal?(:Proc)
        end

      end # Send
    end # Meta
  end # AST
end # Mutant
