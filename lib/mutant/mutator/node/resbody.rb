# encoding: UTF-8

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
        #
        # @api private
        #
        def dispatch
          emit_assignment(nil)
          emit_body_mutations if body
          mutate_captures
        end

        # Mutate captures
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_captures
          return unless captures
          Util::Array.each(captures.children, self) do |matchers|
            next if matchers.empty? || matchers.any? { |node| node.type == :nil }
            emit_captures(s(:array, *matchers))
          end
        end

      end # Resbody
    end # Node
  end # Mutator
end # Mutant
