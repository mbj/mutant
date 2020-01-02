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
          name = Mutant::Util.one(argument.children)

          emit_type(s(:arg, :"_#{name}")) unless name.to_s.start_with?('_')
        end
      end # ProcargZero
    end # Node
  end # Mutator
end # Mutant
