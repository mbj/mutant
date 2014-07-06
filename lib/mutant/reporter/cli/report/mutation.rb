module Mutant
  class Reporter
    class CLI
      class Report

        # Reporter for mutations
        class Mutation < self

          handle Mutant::Result::Mutation

          delegate :mutation

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
            "-----------------------\n".freeze

          NOOP_MESSAGE    =
            "--- Noop failure ---\n" \
            "No code was inserted. And the test did NOT PASS.\n" \
            "This is typically a problem of your specs not passing unmutated.\n" \
            "--------------------\n".freeze

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts(mutation.identification)
            puts(details)
            self
          end

        private

          # Return details
          #
          # @return [String]
          #
          # @api private
          #
          def details
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
            diff || DIFF_ERROR_MESSAGE
          end

          # Noop details
          #
          # @return [String]
          #
          # @api private
          #
          def noop_details
            NOOP_MESSAGE
          end

          # Neutral details
          #
          # @return [String]
          #
          # @api private
          #
          def neutral_details
            format(NEUTRAL_MESSAGE, mutation.subject.node.inspect, mutation.source)
          end

        end # Mutation
      end # Report
    end # CLI
  end # Reporter
end # Mutant
