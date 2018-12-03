# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class ProcargZero < self
        MAP = {
          ::Parser::AST::Node => :emit_argument_node_mutations,
          Symbol              => :emit_argument_symbol_mutations
        }.freeze

        private_constant(*constants(false))

        handle :procarg0

        children :argument

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          __send__(MAP.fetch(argument.class))
        end

        # Emit argument symbol mutations
        #
        # @return [undefined]
        def emit_argument_symbol_mutations
          emit_type(:"_#{argument}") unless argument.to_s.start_with?('_')
        end

        # Emit argument node mutations
        #
        # @return [undefined]
        def emit_argument_node_mutations
          emit_argument_mutations
          first = Mutant::Util.one(argument.children)
          emit_type(first)
        end
      end # ProcargZero
    end # Node
  end # Mutator
end # Mutant
