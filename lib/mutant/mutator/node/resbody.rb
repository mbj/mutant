# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for resbody nodes
      class Resbody < self

        handle(:resbody)

        children :captures, :assignment, :body

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_assignment(nil)
          emit_body_mutations if body
          mutate_captures
        end

        # Mutate captures
        #
        # @return [undefined]
        def mutate_captures
          return unless captures
          Util::Array::Element.call(captures.children).each do |matchers|
            next if matchers.any?(&method(:n_nil?))
            emit_captures(s(:array, *matchers))
          end
        end

      end # Resbody
    end # Node
  end # Mutator
end # Mutant
