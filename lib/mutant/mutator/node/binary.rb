module Mutant
  class Mutator
    class Node
      # Mutation emitter to handle binary connectives
      class Binary < self

        INVERSE = {
          and: :or,
          or:  :and
        }.freeze

        handle(*INVERSE.keys)

        children :left, :right

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_promotions
          emit_operator_mutations
          emit_left_negation
          emit_left_mutations
          emit_right_mutations
          emit_fetch_mutation
        end

        # Emit operator mutations
        #
        # @return [undefined]
        def emit_operator_mutations
          emit(s(INVERSE.fetch(node.type), left, right))
        end

        # Emit promotions
        #
        # @return [undefined]
        def emit_promotions
          emit(left)
          emit(right)
        end

        # Emit left negation
        #
        # We do not emit right negation as the `and` and `or` nodes
        # in ruby are also used for control flow.
        #
        # Irrespective of their syntax, aka `||` parses internally to `or`.
        #
        # `do_a or do_b`. Negating left makes sense, negating right
        # only when the result is actually used.
        #
        # It *would* be possible to emit the right negation in case the use of the result is proved.
        # Like parent is an assignment to an {l,i}var. Dunno if we ever get the time to do that.
        #
        # @return [undefined]
        def emit_left_negation
          emit(s(node.type, n_not(left), right))
        end

        # Emit mutation from `a[b] || c` to `a.fetch(b) { c }`
        #
        # @return [undefined]
        def emit_fetch_mutation
          return unless n_send?(left) && n_or?(node)

          send_node = AST::Meta::Send.new(left)
          return unless send_node.selector.equal?(:[]) && send_node.arguments.one?

          emit(
            s(:block,
              s(:send, send_node.receiver, :fetch, *send_node.arguments),
              s(:args),
              right)
          )
        end

      end # Binary
    end # Node
  end # Mutator
end # Mutant
