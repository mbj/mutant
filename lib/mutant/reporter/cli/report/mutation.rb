# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Report

        # Reporter for mutations
        class Mutation < self

          # Reporter for noop mutations
          class Noop < self
            handle(Mutant::Mutation::Neutral::Noop)

            MESSAGE = [
              'Parsed subject AST:',
              '%s',
              'Unparsed source:',
              '%s'
            ].join("\n").freeze

            # Run report printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              puts(MESSAGE % [object.subject.node.inspect, object.original_source])
              self
            end
          end # Noop

          # Reporter for mutations producing a diff
          class Diff < self
            handle(Mutant::Mutation::Evil)
            handle(Mutant::Mutation::Neutral)

            delegate :subject

            # Run report printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              original, current = object.original_source, object.source
              diff = Mutant::Diff.build(original, current)
              puts(color? ? diff.colorized_diff : diff.diff)
              self
            end
          end
        end

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
          end

        end # Mutation
      end # Report
    end # CLI
  end # Reporter
end # Mutant
