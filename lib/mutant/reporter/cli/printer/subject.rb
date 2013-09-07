# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer

        # Subject results printer
        class Subject < self

          handle(Mutant::Subject)

          # Run subject results printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            info('%s', object.identification)
          end

          # Printer for subject runners
          class Runner < self

            handle(Mutant::Runner::Subject)

            # Run printer
            #
            # @return [undefined]
            #
            # @api private
            #
            def run
              print_progress_bar_finish
              print_stats
              self
            end

          private

            # Return mutation time on subject
            #
            # @return [Float]
            #
            # @api private
            #
            def time
              mutations.map(&:runtime).inject(0, :+)
            end

            # Return subject
            #
            # @return [Subject]
            #
            # @api private
            #
            def subject
              object.subject
            end

            FORMAT = '(%02d/%02d) %3d%% - %0.02fs'.freeze

            # Print stats
            #
            # @return [undefned
            #
            # @api private
            #
            def print_stats
              status(FORMAT, amount_kills, amount_mutations, coverage, time)
            end

            # Print progress bar finish
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_progress_bar_finish
              puts unless amount_mutations.zero?
            end

            # Return kills
            #
            # @return [Fixnum]
            #
            # @api private
            #
            def amount_kills
              fails = object.failed_mutations
              fails = fails.length
              amount_mutations - fails
            end

            # Return amount of mutations
            #
            # @return [Array<Mutation>]
            #
            # @api private
            #
            def amount_mutations
              mutations.length
            end

            # Return mutations
            #
            # @return [Array<Mutation>]
            #
            # @api private
            #
            def mutations
              object.mutations
            end

            # Return suject coverage
            #
            # @return [Float]
            #
            # @api private
            #
            def coverage
              return 0 if amount_mutations.zero?
              Rational(amount_kills, amount_mutations) * 100
            end

            # Detailed subject printer
            class Details < self

              # Run subject details printer
              #
              # @return [undefined]
              #
              # @api private
              #
              def run
                puts(subject.identification)
                object.failed_mutations.each do |mutation|
                  visit(mutation)
                end
                print_stats
              end

            end # Details
          end # Runner
        end # Subject
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
