module Mutant
  class Mutator
    class Node
      # Mutator for resbody nodes
      class Resbody < self

        handle(:resbody)

        children :captures, :assignment, :block

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_assignment(nil)
          emit_block_mutations if block
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
          emit_captures(nil)
          Util::Array.each(captures.children, self) do |matchers|
            next if matchers.empty?
            emit_captures(s(:array, *matchers))
            # p capture
            # emit_captures(s(:array, *capture))
          end
        end

      end # Resbody
    end # Node
  end # Mutator
end # Mutant
