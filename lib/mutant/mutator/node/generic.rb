module Mutant
  class Mutator
    class Node

      # Generic mutator
      class Generic < self

        handle(:self)

        # These nodes still need a dedicated mutator,
        # your contribution is that close!
        handle(
          :zsuper, :not, :or, :and, :defined,
          :next, :break, :match, :gvar, :cvar, :ensure,
          :dstr, :dsym, :yield, :rescue, :redo, :defined?,
          :const, :blockarg, :block_pass, :op_asgn, :and_asgn,
          :regopt, :ivar, :restarg, :casgn, :resbody, :retry, :arg_expr,
          :kwrestarg, :kwoptarg, :kwarg, :undef, :module, :cbase, :empty,
          :alias, :for, :xstr, :back_ref, :nth_ref, :class,
          :sclass, :match_with_lvasgn, :match_current_line, :or_asgn, :kwbegin
        )

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          children.each_with_index do |child, index|
            next unless child.kind_of?(Parser::AST::Node)
            mutate_child(index)
          end
        end

      end # Generic
    end # Node
  end # Mutator
end # Mutant
