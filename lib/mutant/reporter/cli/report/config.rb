module Mutant
  class Reporter
    class CLI
      class Report

        # Printer for configuration
        class Config < self

          handle(Mutant::Runner::Config)

          delegate(
            :amount_kills, :amount_mutations, :amount_kils,
            :coverage, :subjects, :failed_subjects, :runtime, :mutations
          )

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            failed_subjects.each(&method(:visit))
            info 'Subjects:  %s',      amount_subjects
            info 'Mutations: %s',      amount_mutations
            info 'Kills:     %s',      amount_kills
            info 'Alive:     %s',      amount_alive
            info 'Runtime:   %0.2fs',  runtime
            info 'Killtime:  %0.2fs',  killtime
            info 'Overhead:  %0.2f%%', overhead
            status 'Coverage:  %0.2f%%', coverage
            status 'Expected:  %0.2f%%', object.config.expected_coverage
            print_generic_stats
            self
          end

        private

          # Print generic stats
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_generic_stats
            stats = generic_stats.to_a.sort_by(&:last)
            return if stats.empty?
            info('Nodes handled by generic mutator (type:occurrences):')
            stats.reverse_each do |type, amount|
              info('%-10s: %d', type, amount)
            end
          end

          # Return stats for nodes handled by generic mutator
          #
          # @return [Hash<Symbo, Fixnum>]
          #
          # @api private
          #
          def generic_stats
            subjects.each_with_object(Hash.new(0)) do |runner, stats|
              Walker.run(runner.subject.node) do |node|
                if Mutator::Registry.lookup(node).equal?(Mutator::Node::Generic)
                  stats[node.type] += 1
                end
              end
            end
          end

          # Return amount of subjects
          #
          # @return [Fixnum]
          #
          # @api private
          #
          def amount_subjects
            subjects.length
          end

          # Return amount of time in killers
          #
          # @return [Float]
          #
          # @api private
          #
          def killtime
            mutations.map(&:runtime).inject(0, :+)
          end
          memoize :killtime

          # Return mutant overhead
          #
          # @return [Float]
          #
          # @api private
          #
          def overhead
            return 0 if runtime.zero?
            Rational(runtime - killtime, runtime) * 100
          end

          # Return amount of alive mutations
          #
          # @return [Fixnum]
          #
          # @api private
          #
          def amount_alive
            object.amount_mutations - amount_kills
          end

        end # Config
      end # Report
    end # CLI
  end # Reporter
end # Mutant
