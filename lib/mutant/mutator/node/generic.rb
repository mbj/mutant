# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Generic mutator
      class Generic < self

        # These nodes still need a dedicated mutator,
        # your contribution is that close!
        handle(
          :next, :break, :ensure,
          :yield, :rescue, :redo, :defined?,
          :blockarg,
          :regopt, :resbody, :retry, :arg_expr,
          :kwrestarg, :kwoptarg, :kwarg, :undef, :module, :empty,
          :alias, :for, :xstr, :back_ref, :class,
          :sclass, :match_with_lvasgn, :match_current_line, :kwbegin
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
