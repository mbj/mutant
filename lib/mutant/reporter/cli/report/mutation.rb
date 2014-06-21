module Mutant
  class Reporter
    class CLI
      class Report

        # Reporter for mutations
        class Mutation < self

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts(object.identification)
            puts(details)
            self
          end

          # Reporter for noop mutations
          class Noop < self
            handle(Mutant::Mutation::Neutral::Noop)

            MESSAGE = [
              'Parsed subject AST:',
              '%s',
              'Unparsed source:',
              '%s'
            ].join("\n").freeze

            delegate :killers

          private

            # Return details
            #
            # @return [self]
            #
            # @api private
            #
            def details
              info(MESSAGE, object.subject.node.inspect, object.original_source)
            end

          end # Noop

          # Reporter for mutations producing a diff
          class Diff < self
            handle(Mutant::Mutation::Evil)
            handle(Mutant::Mutation::Neutral)

            DIFF_ERROR_MESSAGE = 'BUG: Mutation NOT resulted in exactly one diff. Please report a reproduction'.freeze

          private

            # Run report printer
            #
            # @return [String]
            #
            # @api private
            #
            def details
              original, current = object.original_source, object.source
              diff = Mutant::Diff.build(original, current)
              diff = color? ? diff.colorized_diff : diff.diff
              diff || DIFF_ERROR_MESSAGE
            end
          end # Diff
        end # Mutation

        # Subject report printer
        class MutationRunner < self
          handle(Mutant::Runner::Mutation)

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            visit(object.mutation)
            if object.mutation.kind_of?(Mutant::Mutation::Neutral::Noop)
              report_noop
            end
            self
          end

          delegate :killers

        private

          # Report noop output
          #
          # @return [undefined]
          #
          # @api private
          #
          def report_noop
            info('NOOP MUTATION TESTS FAILED!')
            noop_reports.each do |report|
              puts(report.test.identification)
              puts(report.output)
            end
          end

          # Return test noop reports
          #
          # @return [Enumerable<Test::Report>]
          #
          # @api private
          #
          def noop_reports
            killers.reject(&:success?).map(&:report).map(&:test_report)
          end

        end # Mutation
      end # Report
    end # CLI
  end # Reporter
end # Mutant
