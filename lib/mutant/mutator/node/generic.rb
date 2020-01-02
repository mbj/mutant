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
          blockarg_expr
          complex
          eflipflop
          empty
          ensure
          for
          ident
          iflipflop
          kwnilarg
          kwrestarg
          kwsplat
          match_with_lvasgn
          meth_ref
          module
          numargs
          numblock
          numparam
          objc_kwarg
          objc_restarg
          objc_varargs
          postexe
          preexe
          rational
          redo
          restarg
          restarg_expr
          retry
          root
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
