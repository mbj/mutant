# frozen_string_literal: true

module Mutant
  class Reporter
    class CliCompact
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

          NOOP_MESSAGE = <<~'MESSAGE'
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
          MESSAGE

          SEPARATOR = '-----------------------'

          # Run report printer
          #
          # @return [undefined]
          def run
            puts(mutation.identification)
            puts(SEPARATOR)
            print_details
            puts(SEPARATOR)
          end

        private

          def print_details
            __send__(MAP.fetch(mutation.class))
          end

          def evil_details
            visit(Mutation, mutation)
          end

          def noop_details
            info(NOOP_MESSAGE)
          end

          def neutral_details
            info(NEUTRAL_MESSAGE, mutation.node.inspect, mutation.source)
          end

        end # MutationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
