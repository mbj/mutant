module Mutant
  class Mutator
    class Node
      # Mutator that does not do mutations on ast
      class Noop < self

        # Literal references to self do not need to be mutated?
        handle(:self)

        # These nodes still need a mutator, your contribution is that close!
        handle(
          :zsuper, :not, :or, :and, :defined,
          :next, :break, :match, :gvar, :cvar, :ensure,
          :dstr, :dsym, :yield, :rescue, :redo, :defined?,
          :lvar, :splat, :const, :blockarg, :block_pass, :op_asgn, :regopt,
          :ivar, :restarg, :casgn, :masgn, :resbody, :retry, :arg_expr,
          :kwrestarg, :kwoptarg, :kwarg, :undef, :module, :cbase, :empty,
          :alias, :for, :xstr, :back_ref, :nth_ref, :class, :sclass, :match_with_lvasgn,
          :match_current_line, :or_asgn
        )

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
        end

      end # Noop
    end # Node
  end # Mutator
end # Mutant
