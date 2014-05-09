# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer
        # Mutation printer
        class Mutation < self

          handle(Mutant::Mutation)

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
            lookup(mutation.class).new(runner, output)
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

            handle(Mutant::Mutation::Neutral::Noop)

            MESSAGE = [
              'Parsed subject AST:',
              '%s',
              'Unparsed source:',
              '%s'
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

            handle(Mutant::Mutation::Neutral)
            handle(Mutant::Mutation::Evil)

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
