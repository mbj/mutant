module Mutant
  class Mutator
    class Node
      class FormalArguments19

        # Mutator that expands pattern arguments
        class PatternArgumentExpansion < Node

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            node.required.each_with_index do |argument, index|
              next unless argument.kind_of?(Rubinius::AST::PatternArguments)
              dup = dup_node
              required = dup.required
              required.delete_at(index)
              argument.arguments.body.reverse.each do |node|
                required.insert(index, node.name)
              end
              dup.names |= required
              emit(dup)
            end
          end

        end
      end
    end
  end
end
