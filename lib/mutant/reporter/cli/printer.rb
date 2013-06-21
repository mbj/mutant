module Mutant
  class Reporter
    class CLI

      # CLI printer base class
      class Printer
        include AbstractType, Adamantium::Flat, Concord.new(:output, :runner)

        def self.run(*args)
          new(*args).run
        end

      private

        def puts(string = NL)
          output.puts(string)
        end

        abstract_method :run

        # Config results printer
        class Config < self

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts "Subjects:  #{subjects.length}"
            puts "Mutations: #{amount_mutations}"
            puts "Kills:     #{amount_kills}"
            puts 'Runtime:   %0.2fs' % runtime
            puts 'Killtime:  %0.2fs' % killtime
            puts 'Overhead:  %0.2f%%' % overhead
            puts 'Coverage:  %0.2f%%' % coverage
            self
          end

        private

          # Return subjects
          #
          # @return [Array<Subject>]
          #
          # @api private
          #
          def subjects
            runner.subjects
          end

          # Return mutations
          #
          # @return [Array<Mutation>]
          #
          # @api private
          #
          def mutations
            subjects.map(&:mutations).flatten
          end
          memoize :mutations

          # Return amount of mutations
          #
          # @return [Fixnum]
          #
          # @api private
          #
          def amount_mutations
            mutations.length
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

          # Return amount of kills
          #
          # @return [Fixnum]
          #
          # @api private
          #
          def amount_kills
            mutations.select(&:success?).length
          end

          # Return mutant overhead
          #
          # @return [Float]
          #
          # @api private
          #
          def overhead
            (runtime - killtime) / runtime * 100
          end

          # Return runtime
          #
          # @return [Float]
          #
          # @api private
          #
          def runtime
            runner.runtime
          end

          # Return coverage
          #
          # @return [Float]
          #
          # @api private
          #
          def coverage
            amount_kills / amount_mutations * 100
          end
        end # Config

        # Subject results printer
        class Subject < self

          # Run printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            puts
            puts('(%02d/%02d) %3d%% - %0.02fs' % [amount_kills, amount_mutations, coverage, time])
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

          # Return kills
          #
          # @return [Fixnum]
          #
          # @api private
          #
          def amount_kills
            fails = runner.failed_mutations
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
            runner.mutations
          end

          # Return suject coverage
          #
          # @return [Float]
          #
          # @api private
          #
          def coverage
            coverage  = amount_kills.to_f / amount_mutations * 100
          end

        end # Subject
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
