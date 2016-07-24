module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for mutation results
        #
        # :reek:TooManyConstants
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
          def run
            puts(mutation.identification)
            print_details
            puts(FOOTER)
          end

        private

          # Print mutation details
          #
          # @return [undefined]
          def print_details
            __send__(MAP.fetch(mutation.class))
          end

          # Evil mutation details
          #
          # @return [String]
          def evil_details
            diff = Diff.build(mutation.original_source, mutation.source)
            diff = color? ? diff.colorized_diff : diff.diff
            if diff
              output.write(diff)
            else
              print_no_diff_message
            end
          end

          # Print no diff message
          #
          # @return [undefined]
          def print_no_diff_message
            info(
              NO_DIFF_MESSAGE,
              mutation.original_source,
              original_node.inspect,
              mutation.source,
              mutation.node.inspect
            )
          end

          # Noop details
          #
          # @return [String]
          def noop_details
            info(NOOP_MESSAGE)
            visit_test_result
          end

          # Neutral details
          #
          # @return [String]
          def neutral_details
            info(NEUTRAL_MESSAGE, original_node.inspect, mutation.source)
            visit_test_result
          end

          # Visit failed test results
          #
          # @return [undefined]
          def visit_test_result
            visit(TestResult, test_result)
          end

          # Original node
          #
          # @return [Parser::AST::Node]
          def original_node
            mutation.subject.node
          end

        end # MutationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
