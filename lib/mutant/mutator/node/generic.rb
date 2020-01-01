# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Generic mutator
      class Generic < self

        unsupported_nodes = %i[
          __FILE__
          __LINE__
          alias
          arg_expr
          back_ref
          blockarg
          complex
          eflipflop
          empty
          ensure
          for
          ident
          iflipflop
          kwrestarg
          kwsplat
          match_with_lvasgn
          module
          postexe
          preexe
          rational
          redo
          restarg
          retry
          sclass
          shadowarg
          undef
          until_post
          while_post
          xstr
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
