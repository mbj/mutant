# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer
        # Mutation printer
        class Mutation < self

          handle(Runner::Mutation)

          # Build printer
          #
          # @param [Runner::Mutation] runner
          # @param [IO] output
          #
          # @return [Printer::Mutation]
          #
          # @api private
          #
          def self.build(runner, output)
            mutation = runner.mutation
            case mutation
            when Mutant::Mutation::Neutral::Noop
              Noop
            when Mutant::Mutation::Evil, Mutant::Mutation::Neutral
              Diff
            else
              raise "Unknown mutation: #{mutation}"
            end.new(runner, output)
          end

          # Run mutation printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            status('%s', mutation.identification)
            puts(details)
          end

        private

          # Return mutation
          #
          # @return [Mutation]
          #
          # @api private
          #
          def mutation
            object.mutation
          end

          # Reporter for noop mutations
          class Noop < self

          MESSAGE = [
            'Parsed subject AST:',
            '%s',
            'Unparsed source:',
            '%s',
          ].join("\n")

          private

            # Return details
            #
            # @return [String]
            #
            # @api private
            #
            def details
              sprintf(
                MESSAGE,
                mutation.subject.node.inspect,
                mutation.original_source
              )
            end

          end # Noop

          # Reporter for neutral and evil mutations
          class Diff < self

            # Return diff
            #
            # @return [String]
            #
            # @api private
            #
            def details
              original, current = mutation.original_source, mutation.source
              differ = Differ.build(original, current)
              color? ? differ.colorized_diff : differ.diff
            end

          end # Evil

        end # Mutantion
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
