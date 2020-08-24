# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for mutation results
        class MutationResult < self

          delegate :mutation, :isolation_result

          MAP = {
            Mutant::Mutation::Evil    => :evil_details,
            Mutant::Mutation::Neutral => :neutral_details,
            Mutant::Mutation::Noop    => :noop_details
          }.freeze

          NEUTRAL_MESSAGE = <<~'MESSAGE'
            --- Neutral failure ---
            Original code was inserted unmutated. And the test did NOT PASS.
            Your tests do not pass initially or you found a bug in mutant / unparser.
            Subject AST:
            %s
            Unparsed Source:
            %s
          MESSAGE

          NO_DIFF_MESSAGE = <<~'MESSAGE'
            --- Internal failure ---
            BUG: A generted mutation did not result in exactly one diff hunk!
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

          NOOP_MESSAGE = <<~'MESSAGE'
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
          MESSAGE

          FOOTER = '-----------------------'

          # Run report printer
          #
          # @return [undefined]
          def run
            puts(mutation.identification)
            print_details
            puts(FOOTER)
          end

        private

          def print_details
            __send__(MAP.fetch(mutation.class))

            puts(FOOTER)
            visit_isolation_result
          end

          def evil_details
            diff = Diff.build(mutation.original_source, mutation.source)
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
              mutation.original_source,
              original_node.inspect,
              mutation.source,
              mutation.node.inspect
            )
          end

          def noop_details
            info(NOOP_MESSAGE)
          end

          def neutral_details
            info(NEUTRAL_MESSAGE, original_node.inspect, mutation.source)
          end

          def visit_isolation_result
            visit(IsolationResult, isolation_result)
          end

          def original_node
            mutation.subject.node
          end

        end # MutationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
