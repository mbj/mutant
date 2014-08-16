module Mutant
  class Mutator
    class Node
      # Mutator for rescue nodes
      class Rescue < self

        handle :rescue

        children :body

        define_named_child(:else_body, -1)

        RESCUE_INDICES = (1..-2).freeze

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          mutate_body
          mutate_rescue_bodies
          mutate_else_body
        end

      private

        # Mutate child by name
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_rescue_bodies
          children_indices(RESCUE_INDICES).each do |index|
            next unless children.at(index)
            mutate_child(index)
          end
        end

        # Emit concatenation with body
        #
        # @param [Parser::AST::Node] child
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_concat(child)
          raise unless body
          emit(s(:begin, body, child))
        end

        # Emit body mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_body
          return unless body
          emit_body_mutations
          emit(body)
        end

        # Emit else body mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_else_body
          return unless else_body
          emit_else_body_mutations
          emit_concat(else_body)
        end

      end # Rescue
    end # Node
  end # Mutator
end # Mutant
