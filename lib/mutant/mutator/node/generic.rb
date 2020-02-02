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
          array_pattern
          array_pattern_with_tail
          back_ref
          blockarg
          blockarg_expr
          case_match
          complex
          const_pattern
          eflipflop
          empty
          ensure
          for
          forward_args
          forwarded_args
          hash_pattern
          ident
          if_guard
          iflipflop
          in_match
          in_pattern
          kwnilarg
          kwrestarg
          kwsplat
          match_alt
          match_as
          match_nil_pattern
          match_rest
          match_var
          match_with_lvasgn
          match_with_trailing_comma
          module
          numargs
          numblock
          objc_kwarg
          objc_restarg
          objc_varargs
          pin
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
          unless_guard
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
