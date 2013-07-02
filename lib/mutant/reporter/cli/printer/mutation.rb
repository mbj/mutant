module Mutant
  class Reporter
    class CLI
      class Printer
        # Mutation printer
        class Mutation < self

          # Run mutation printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            status(mutation.identification)
            puts(colorized_diff)
          end

        private

          # Return mutation
          #
          # @return [Mutation]
          #
          # @api private
          #
          def mutation
            object.mutation
          end

          # Return colorized diff
          #
          # @param [Mutation] mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def colorized_diff
            original, current = mutation.original_source, mutation.source
            differ = Differ.build(original, current)
            diff = color? ? differ.colorized_diff : differ.diff

            if diff.empty?
              raise 'Unable to create a diff, so ast mutant or unparser does something strange!!'
            end

            diff
          end

        end # Mutantion
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
