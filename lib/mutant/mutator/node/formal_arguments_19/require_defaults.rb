module Mutant
  class Mutator
    class Node
      class FormalArguments19

        # Mutator for removing defaults and transform them into required arguments
        class RequireDefaults < Node

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            return unless node.defaults
            arguments = node.defaults.arguments
            arguments.each_index do |index|
              names = arguments.take(index+1).map(&:name)
              dup = dup_node
              defaults = dup.defaults
              defaults.arguments = defaults.arguments.drop(names.size)
              names.each { |name| dup.optional.delete(name) }
              dup.required.concat(names)
              if dup.optional.empty?
                dup.defaults = nil
              end
              emit(dup)
            end
          end
        end
      end
    end
  end
end
