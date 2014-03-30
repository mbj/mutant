# encoding: utf-8

module Mutant
  class Mutator
    class Util

      # Mutators that mutates an array of inputs
      class Array < self

        handle(::Array)

        # Element presence mutator
        class Presence < Util

        private

          # Emit element presence mutations
          #
          # @return [undefined]
          #
          # @api private
          #
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
          #
          # @api private
          #
          def dispatch
            input.each_with_index do |element, index|
              Mutator.each(inherit_context(element, parent)).each do |mutation|
                dup = dup_input
                dup[index] = mutation
                emit(dup)
              end
            end
          end

        end # Element

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          run(Element, parent)
          run(Presence, parent)
          emit([])
        end

      end # Array
    end # Node
  end # Mutant
end # Mutator
