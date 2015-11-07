module Mutant
  class Reporter
    class Hash
      class Printer
        # Reporter for mutation results
        class MutationResult < self

          delegate :mutation, :test_result

          DIFF_ERROR_MESSAGE =
            'BUG: Mutation NOT resulted in exactly one diff hunk. Please report a reproduction!'.freeze

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
            "Test Result:\n".freeze

          NO_DIFF_MESSAGE =
            "--- Internal failure ---\n" \
            "BUG: Mutation NOT resulted in exactly one diff hunk. Please report a reproduction!\n" \
            "Original unparsed source:\n" \
            "%s\n" \
            "Original AST:\n" \
            "%s\n" \
            "Mutated unparsed source:\n" \
            "%s\n" \
            "Mutated AST:\n" \
            "%s\n".freeze

          NOOP_MESSAGE    =
            "---- Noop failure -----\n" \
            "No code was inserted. And the test did NOT PASS.\n" \
            "This is typically a problem of your specs not passing unmutated.\n" \
            "Test Result:\n".freeze

          FOOTER = '-----------------------'.freeze

          # Run report printer
          #
          # @return [undefined]
          #
          # @api private
          def run
            {
              identification: mutation.identification,
              details: print_details
            }
          end

        private

          # Print mutation details
          #
          # @return [undefined]
          #
          # @api private
          def print_details
            __send__(MAP.fetch(mutation.class))
          end

          # Evil mutation details
          #
          # @return [String]
          #
          # @api private
          def evil_details
            diff = Diff.build(mutation.original_source, mutation.source)
            diff = false ? diff.colorized_diff : diff.diff
            if diff
              diff
            else
              print_no_diff_message
            end
          end

          # Print no diff message
          #
          # @return [undefined]
          #
          # @api private
          def print_no_diff_message
            NO_DIFF_MESSAGE % [
                mutation.original_source,
                original_node.inspect,
                mutation.source,
                mutation.node.inspect
              ]
          end

          # Noop details
          #
          # @return [String]
          #
          # @api private
          def noop_details
            {
              type: 'noop',
              message: NOOP_MESSAGE,
              result: visit_test_result
            }
          end

          # Neutral details
          #
          # @return [String]
          #
          # @api private
          def neutral_details
            {
              type: 'neutral',
              message: NEUTRAL_MESSAGE % [original_node.inspect, mutation.source],
              result: visit_test_result
            }
          end

          # Visit failed test results
          #
          # @return [undefined]
          #
          # @api private
          def visit_test_result
            visit(TestResult, test_result)
          end

          # Original node
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          def original_node
            mutation.subject.node
          end

        end # MutationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
