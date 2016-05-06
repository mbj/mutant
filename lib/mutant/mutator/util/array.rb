module Mutant
  class Mutator
    class Util

      # Mutators that mutates an array of inputs
      class Array < self

        # Element presence mutator
        class Presence < Util

        private

          # Emit element presence mutations
          #
          # @return [undefined]
          def dispatch
            input.each_index do |index|
              dup = dup_input
              dup.delete_at(index)
              emit(dup)
            end
          end

        end # Presence

        # Array element mutator
        class Element < Util

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            input.each_with_index do |element, index|
              Mutator.mutate(element).each do |mutation|
                dup = dup_input
                dup[index] = mutation
                emit(dup)
              end
            end
          end

        end # Element
      end # Array
    end # Util
  end # Mutator
end # Mutant
