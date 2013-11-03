# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer

        # Printer for configuration
        class Config < self

          handle(Mutant::Config)

          # Report configuration
          #
          # @param [Mutant::Config] config
          #
          # @return [self]
          #
          # @api private
          #
          def run
            info 'Mutant configuration:'
            info 'Matcher:        %s', object.matcher.inspect
            info 'Subject Filter: %s', object.subject_predicate.inspect
            info 'Strategy:       %s', object.strategy.inspect
            self
          end

          # Config results printer
          class Runner < self

            handle(Mutant::Runner::Config)

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              print_mutations
              info   'Subjects:  %s',      amount_subjects
              info   'Mutations: %s',      amount_mutations
              info   'Kills:     %s',      amount_kills
              info   'Runtime:   %0.2fs',  runtime
              info   'Killtime:  %0.2fs',  killtime
              info   'Overhead:  %0.2f%%', overhead
              status 'Coverage:  %0.2f%%', coverage
              status 'Alive:     %s',      amount_alive
              print_generic_stats
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
              object.subjects
            end

            # Walker for all ast nodes
            class Walker

              # Run walkter
              #
              # @param [Parser::AST::Node] root
              #
              # @return [self]
              #
              # @api private
              #
              def self.run(root, &block)
                new(root, block)
                self
              end

              private_class_method :new

              # Initialize and run walker
              #
              # @param [Parser::AST::Node] root
              # @param [#call(node)] block
              #
              # @return [undefined]
              #
              # @api private
              #
              def initialize(root, block)
                @root, @block = root, block
                dispatch(root)
              end

            private

              # Perform dispatch
              #
              # @return [undefined]
              #
              # @api private
              #
              def dispatch(node)
                @block.call(node)
                node.children.grep(Parser::AST::Node).each(&method(:dispatch))
              end
            end

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
              object.subjects.each_with_object(Hash.new(0)) do |runner, stats|
                Walker.run(runner.subject.node) do |node|
                  if Mutator::Registry.lookup(node) == Mutator::Node::Generic
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

            # Print mutations
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_mutations
              object.failed_subjects.each do |subject|
                Subject::Runner::Details.run(subject, output)
              end
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
              return 0 if runtime.zero?
              Rational(runtime - killtime, runtime) * 100
            end

            # Return runtime
            #
            # @return [Float]
            #
            # @api private
            #
            def runtime
              object.runtime
            end

            # Return coverage
            #
            # @return [Float]
            #
            # @api private
            #
            def coverage
              return 0 if amount_mutations.zero?
              Rational(amount_kills, amount_mutations) * 100
            end

            # Return amount of alive mutations
            #
            # @return [Fixnum]
            #
            # @api private
            #
            def amount_alive
              amount_mutations - amount_kills
            end

          end # Runner
        end # Config
      end # Printer
    end # Cli
  end # Reporter
end # Mutant
