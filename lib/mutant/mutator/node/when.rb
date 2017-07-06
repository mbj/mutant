module Mutant
  class Mutator
    class Node

      # Mutator for when nodes
      class When < self

        handle(:when)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          if body
            mutate_body
          else
            emit_child_update(body_index, N_RAISE)
          end
          mutate_conditions
        end

        # Emit condition mutations
        #
        # @return [undefined]
        def mutate_conditions
          conditions = children.length - 1
          children[0..-2].each_index do |index|
            delete_child(index) if conditions > 1
            mutate_child(index)
          end
        end

        # Emit body mutations
        #
        # @return [undefined]
        def mutate_body
          mutate_child(body_index)
        end

        # Body node
        #
        # @return [Parser::AST::Node]
        #   if body is present
        #
        # @return [nil]
        #   otherwise
        def body
          children.fetch(body_index)
        end

        # Index of body node
        #
        # @return [Integer]
        def body_index
          children.length - 1
        end

      end # When
    end # Node
  end # Mutator
end # Mutant
