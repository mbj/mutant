# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Generic mutator
      class Generic < self

        # These nodes still need a dedicated mutator,
        # your contribution is that close!
        handle(
          :ensure, :redo, :defined?, :regopt, :retry, :arg_expr,
          :kwrestarg, :kwoptarg, :kwarg, :undef, :module, :empty,
          :alias, :for, :xstr, :back_ref, :class,
          :sclass, :match_with_lvasgn, :while_post,
          :until_post, :preexe, :postexe, :iflipflop, :eflipflop, :kwsplat,
          :shadowarg
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
            mutate_child(index) if child.kind_of?(Parser::AST::Node)
          end
        end

      end # Generic
    end # Node
  end # Mutator
end # Mutant
