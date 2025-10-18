# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for mutations
        class Mutation < self
          NO_DIFF_MESSAGE = <<~'MESSAGE'
            --- Internal failure ---
            BUG: A generated mutation did not result in exactly one diff hunk!
            This is an invariant violation by the mutation generation engine.
            Please report a reproduction to https://github.com/mbj/mutant
            Original unparsed source:
            %s
            Original AST:
            %s
            Mutated unparsed source:
            %s
            Mutated AST:
            %s
          MESSAGE

          SEPARATOR = '-----------------------'

          # Run report printer
          #
          # @return [undefined]
          def run
            diff = object.diff
            diff = color? ? diff.colorized_diff : diff.diff

            if diff
              output.write(diff)
            else
              print_no_diff_message
            end
          end

          def print_no_diff_message
            info(
              NO_DIFF_MESSAGE,
              object.original_source,
              original_node.inspect,
              object.source,
              object.node.inspect
            )
          end

          def original_node
            object.subject.node
          end

        end # MutationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
