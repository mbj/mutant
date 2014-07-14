module Mutant
  class Reporter
    class CLI
      class Report

        # Env result reporter
        class Env < self

          handle(Result::Env)

          delegate(
            :coverage, :failed_subject_results, :amount_subjects, :amount_mutations,
            :amount_mutations_alive, :amount_mutations_killed, :runtime, :killtime, :overhead, :env
          )

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            visit_collection(failed_subject_results)
            info 'Subjects:  %s',        amount_subjects
            info 'Mutations: %s',        amount_mutations
            info 'Kills:     %s',        amount_mutations_killed
            info 'Alive:     %s',        amount_mutations_alive
            info 'Runtime:   %0.2fs',    runtime
            info 'Killtime:  %0.2fs',    killtime
            info 'Overhead:  %0.2f%%',   overhead_percent
            status 'Coverage:  %0.2f%%', coverage_percent
            status 'Expected:  %0.2f%%', env.config.expected_coverage
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

          # Return coverage percent
          #
          # @return [Float]
          #
          # @api private
          #
          def coverage_percent
            coverage * 100
          end

          # Return overhead percent
          #
          # @return [Float]
          #
          # @api private
          #
          def overhead_percent
            (overhead / killtime) * 100
          end

          # Return stats for nodes handled by generic mutator
          #
          # @return [Hash<Symbo, Fixnum>]
          #
          # @api private
          #
          def generic_stats
            object.subject_results.each_with_object(Hash.new(0)) do |result, stats|
              AST.walk(result.subject.node) do |node|
                stats[node.type] += 1 if Mutator::Registry.lookup(node).equal?(Mutator::Node::Generic)
              end
            end
          end

        end # Env
      end # Report
    end # CLI
  end # Reporter
end # Mutant
