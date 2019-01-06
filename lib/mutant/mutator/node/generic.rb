# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Generic mutator
      class Generic < self

        unsupported_nodes = %i[
          ensure
          redo
          retry
          arg_expr
          blockarg
          kwrestarg
          undef
          module
          empty
          alias
          for
          xstr
          back_ref
          restarg
          sclass
          match_with_lvasgn
          while_post
          until_post
          preexe
          postexe
          iflipflop
          eflipflop
          kwsplat
          shadowarg
          rational
          complex
          __FILE__
          __LINE__
        ]

        # These nodes still need a dedicated mutator,
        # your contribution is that close!
        handle(*unsupported_nodes)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          children.each_with_index do |child, index|
            mutate_child(index) if child.instance_of?(::Parser::AST::Node)
          end
        end

      end # Generic
    end # Node
  end # Mutator
end # Mutant
