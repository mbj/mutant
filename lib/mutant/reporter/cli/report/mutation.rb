module Mutant
  class Reporter
    class CLI
      class Report

        # Reporter for mutations
        class Mutation < self

          handle Mutant::Result::Mutation

          delegate :mutation, :failed_test_results

          DIFF_ERROR_MESSAGE = 'BUG: Mutation NOT resulted in exactly one diff. Please report a reproduction!'.freeze

          MAP = {
            Mutant::Mutation::Evil    => :evil_details,
            Mutant::Mutation::Neutral => :neutral_details,
            Mutant::Mutation::Noop    => :noop_details
          }.freeze

          NEUTRAL_MESSAGE =
            "--- Neutral failure ---\n" \
            "Original code was inserted unmutated. And the test did NOT PASS.\n" \
            "Your tests do not pass initially or you found a bug in mutant / unparser.\n" \
            "Subject AST:\n" \
            "%s\n" \
            "Unparsed Source:\n" \
            "%s\n" \
            "Test Reports: %d\n"

          NOOP_MESSAGE    =
            "---- Noop failure -----\n" \
            "No code was inserted. And the test did NOT PASS.\n" \
            "This is typically a problem of your specs not passing unmutated.\n" \
            "Test Reports: %d\n"

          FOOTER = '-----------------------'.freeze

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts(mutation.identification)
            print_details
            puts(FOOTER)
            self
          end

        private

          # Return details
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_details
            send(MAP.fetch(mutation.class))
          end

          # Return evil details
          #
          # @return [String]
          #
          # @api private
          #
          def evil_details
            original, current = mutation.original_source, mutation.source
            diff = Mutant::Diff.build(original, current)
            diff = color? ? diff.colorized_diff : diff.diff
            info(diff || DIFF_ERROR_MESSAGE)
          end

          # Noop details
          #
          # @return [String]
          #
          # @api private
          #
          def noop_details
            info(NOOP_MESSAGE, failed_test_results.length)
            visit_collection(failed_test_results)
          end

          # Neutral details
          #
          # @return [String]
          #
          # @api private
          #
          def neutral_details
            info(NEUTRAL_MESSAGE, mutation.subject.node.inspect, mutation.source, failed_test_results.length)
            visit_collection(failed_test_results)
          end

        end # Mutation
      end # Report
    end # CLI
  end # Reporter
end # Mutant
