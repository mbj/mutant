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
        def dispatch
          mutate_body
          mutate_rescue_bodies
          mutate_else_body
        end

      private

        # Mutate child by name
        #
        # @return [undefined]
        def mutate_rescue_bodies
          children_indices(RESCUE_INDICES).each do |index|
            mutate_child(index)
            resbody_body = AST::Meta::Resbody.new(children.fetch(index)).body
            emit_concat(resbody_body) if resbody_body
          end
        end

        # Emit concatenation with body
        #
        # @param [Parser::AST::Node] child
        #
        # @return [undefined]
        def emit_concat(child)
          if body
            emit(s(:begin, body, child))
          else
            emit(child)
          end
        end

        # Emit body mutations
        #
        # @return [undefined]
        def mutate_body
          return unless body
          emit_body_mutations
          emit(body)
        end

        # Emit else body mutations
        #
        # @return [undefined]
        def mutate_else_body
          return unless else_body
          emit_else_body_mutations
          emit_concat(else_body)
        end

      end # Rescue
    end # Node
  end # Mutator
end # Mutant
