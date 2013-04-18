module Mutant
  class Mutator
    class Node
      class FormalArguments19

        # Mutator for default argument values
        class DefaultMutations < Node

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            return unless node.defaults
            emit_attribute_mutations(:defaults) do |mutation|
              mutation.optional = mutation.defaults.names
              mutation.names = mutation.required + mutation.optional
              if mutation.defaults.names.empty?
                mutation.defaults = nil
              end
              mutation
            end
          end

        end
      end
    end
  end
end
