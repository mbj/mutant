module Mutant
  class Reporter
    class CLI
      class Progress
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
            puts(object.identification)
          end

        end # Subject

        # Reporter for subject runners
        class SubjectRunner < self

          FORMAT = '(%02d/%02d) %3d%% - %0.02fs'.freeze

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

          # Print stats
          #
          # @return [undefined]
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
            amount_mutations - object.failed_mutations.length
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

          # Return subject coverage
          #
          # @return [Float]
          #
          # @api private
          #
          def coverage
            return 0 if amount_mutations.zero?
            Rational(amount_kills, amount_mutations) * 100
          end

        end # Runner
      end # Progress
    end  # CLI
  end # Reporter
end # Mutant
