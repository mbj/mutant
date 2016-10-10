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

        unsupported_regexp_nodes = AST::Types::REGEXP.to_a - %i[
          regexp_alternation_meta
          regexp_bol_anchor
          regexp_capture_group
          regexp_digit_type
          regexp_eol_anchor
          regexp_eos_ob_eol_anchor
          regexp_greedy_zero_or_more
          regexp_hex_type
          regexp_nondigit_type
          regexp_nonhex_type
          regexp_nonspace_type
          regexp_nonword_boundary_anchor
          regexp_nonword_type
          regexp_root_expression
          regexp_space_type
          regexp_word_boundary_anchor
          regexp_word_type
        ]

        # These nodes still need a dedicated mutator,
        # your contribution is that close!
        handle(*(unsupported_nodes + unsupported_regexp_nodes))

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
