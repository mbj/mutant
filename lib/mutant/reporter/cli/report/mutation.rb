# encoding: utf-8

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

          private

            # Return details
            #
            # @return [self]
            #
            # @api private
            #
            def details
              MESSAGE % [object.subject.node.inspect, object.original_source]
            end

          end # Noop

          # Reporter for mutations producing a diff
          class Diff < self
            handle(Mutant::Mutation::Evil)
            handle(Mutant::Mutation::Neutral)

          private

            # Run report printer
            #
            # @return [self]
            #
            # @api private
            #
            def details
              original, current = object.original_source, object.source
              diff = Mutant::Diff.build(original, current)
              color? ? diff.colorized_diff : diff.diff
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
          end

        end # Mutation
      end # Report
    end # CLI
  end # Reporter
end # Mutant
