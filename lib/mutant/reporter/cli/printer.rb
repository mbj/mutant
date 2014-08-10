module Mutant
  class Reporter
    class CLI
      # CLI runner status printer base class
      class Printer
        include AbstractType, Delegator, Adamantium::Flat, Concord.new(:output, :object)

        NL = "\n".freeze

        # Run printer on object to output
        #
        # @param [IO] output
        # @param [Object] object
        #
        # @return [self]
        #
        # @api private
        #
        def self.run(output, object)
          new(output, object).run
        end

        # Run printer
        #
        # @return [self]
        #
        # @api private
        #
        abstract_method :run

      private

        # Return status color
        #
        # @return [Color]
        #
        # @api private
        #
        def status_color
          success? ? Color::GREEN : Color::RED
        end

        # Visit a collection of objects
        #
        # @return [Class::Printer] printer
        # @return [Enumerable<Object>] collection
        #
        # @return [undefined]
        #
        # @api private
        #
        def visit_collection(printer, collection)
          collection.each do |object|
            visit(printer, object)
          end
        end

        # Visit object
        #
        # @param [Class::Printer] printer
        # @param [Object] object
        #
        # @return [undefined]
        #
        # @api private
        #
        def visit(printer, object)
          printer.run(output, object)
        end

        # Print an info line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def info(string, *arguments)
          puts(format(string, *arguments))
        end

        # Print a status line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def status(string, *arguments)
          puts(colorize(status_color, format(string, *arguments)))
        end

        # Print a line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def puts(string)
          output.puts(string)
        end

        # Test if runner was successful
        #
        # @return [Boolean]
        #
        # @api private
        #
        def success?
          object.success?
        end

        # Colorize message
        #
        # @param [Color] color
        # @param [String] message
        #
        # @api private
        #
        # @return [String]
        #   if color is enabled
        #   unmodified message otherwise
        #
        def colorize(color, message)
          color = Color::NONE unless tty?
          color.format(message)
        end

        # Test if output is a tty
        #
        # @return [Boolean]
        #
        # @api private
        #
        def tty?
          output.tty?
        end

        # Test if output can be colored
        #
        # @return [Boolean]
        #
        # @api private
        #
        alias_method :color?, :tty?

        # Printer for run collector
        class Collector < self

          # Print progress for collector
          #
          # @return [self]
          #
          # @api private
          #
          def run
            visit(EnvProgress, object.result)
            active_subject_results = object.active_subject_results
            info('Active subjects:    %d', active_subject_results.length)
            visit_collection(SubjectProgress, active_subject_results)
            self
          end

        end # Collector

        # Progress printer for configuration
        class Config < self

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
            info 'Matcher:            %s',      object.matcher_config.inspect
            info 'Integration:        %s',      object.integration.name
            info 'Expect Coverage:    %0.2f%%', object.expected_coverage.inspect
            info 'Processes:          %d',      object.processes
            info 'Includes:           %s',      object.includes.inspect
            info 'Requires:           %s',      object.requires.inspect
            self
          end

        end # Config

        # Env progress printer
        class EnvProgress < self

          delegate(
            :coverage,
            :amount_subjects,
            :amount_mutations,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :runtime,
            :killtime,
            :overhead,
            :env
          )

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            visit(Config, env.config)
            info 'Available Subjects: %s',        amount_subjects
            info 'Subjects:           %s',        amount_subjects
            info 'Mutations:          %s',        amount_mutations
            info 'Kills:              %s',        amount_mutations_killed
            info 'Alive:              %s',        amount_mutations_alive
            info 'Runtime:            %0.2fs',    runtime
            info 'Killtime:           %0.2fs',    killtime
            info 'Overhead:           %0.2f%%',   overhead_percent
            status 'Coverage:           %0.2f%%', coverage_percent
            status 'Expected:           %0.2f%%', env.config.expected_coverage
            self
          end

        private

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

        end # EnvProgress

        # Full env result reporter
        class EnvResult < self

          delegate(:failed_subject_results)

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            visit_collection(SubjectResult, failed_subject_results)
            visit(EnvProgress, object)
            self
          end

        private

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

        end # EnvResult

        # Subject report printer
        class SubjectResult < self

          delegate :subject, :failed_mutations

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            status(subject.identification)
            subject.tests.each do |test|
              puts("- #{test.identification}")
            end
            visit_collection(MutationResult, object.alive_mutation_results)
            self
          end

        end # Subject

        # Reporter for subject progress
        class SubjectProgress < self

          FORMAT = '(%02d/%02d) %3d%% - killtime: %0.02fs runtime: %0.02fs overhead: %0.02fs'.freeze

          SUCCESS = '.'.freeze
          FAILURE = 'F'.freeze

          delegate(
            :subject,
            :coverage,
            :runtime,
            :amount_mutations_killed,
            :amount_mutations,
            :amount_mutation_results,
            :killtime,
            :overhead
          )

          # Run printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts("#{subject.identification} mutations: #{amount_mutations}")
            print_tests
            print_mutation_results
            print_progress_bar_finish
            print_stats
            self
          end

        private

          # Print stats
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_stats
            status(
              FORMAT,
              amount_mutations_killed,
              amount_mutations,
              coverage * 100,
              killtime,
              runtime,
              overhead
            )
          end

          # Print tests
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_tests
            subject.tests.each do |test|
              puts "- #{test.identification}"
            end
          end

          # Print progress bar finish
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_progress_bar_finish
            puts(NL) unless amount_mutation_results.zero?
          end

          # Print mutation results
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_mutation_results
            object.mutation_results.each(&method(:print_mutation_result))
          end

          # Print mutation result
          #
          # @param [Result::Mutation] mutation_result
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_mutation_result(mutation_result)
            char(mutation_result.success? ? SUCCESS : FAILURE)
          end

          # Write colorized char
          #
          # @param [String] char
          #
          # @return [undefined]
          #
          # @api private
          #
          def char(char)
            output.write(colorize(status_color, char))
          end

        end # Subject

        # Reporter for mutation results
        class MutationResult < self

          delegate :mutation, :failed_test_results

          DIFF_ERROR_MESSAGE = 'BUG: Mutation NOT resulted in exactly one diff. Please report a reproduction!'.freeze

          MAP = {
            Mutant::Mutation::Evil    => :evil_details,
            Mutant::Mutation::Neutral => :neutral_details,
            Mutant::Mutation::Noop    => :noop_details
          }.freeze

          NEUTRAL_MESSAGE =
            "--- Neutral failure ---\n" \
            "Original code was inserted unmutated. And the test did NOT PASS.\n" \
            "Your tests do not pass initially or you found a bug in mutant / unparser.\n" \
            "Subject AST:\n" \
            "%s\n" \
            "Unparsed Source:\n" \
            "%s\n" \
            "Test Reports: %d\n"

          NOOP_MESSAGE    =
            "---- Noop failure -----\n" \
            "No code was inserted. And the test did NOT PASS.\n" \
            "This is typically a problem of your specs not passing unmutated.\n" \
            "Test Reports: %d\n"

          FOOTER = '-----------------------'.freeze

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            puts(mutation.identification)
            print_details
            puts(FOOTER)
            self
          end

        private

          # Return details
          #
          # @return [undefined]
          #
          # @api private
          #
          def print_details
            send(MAP.fetch(mutation.class))
          end

          # Return evil details
          #
          # @return [String]
          #
          # @api private
          #
          def evil_details
            original, current = mutation.original_source, mutation.source
            diff = Mutant::Diff.build(original, current)
            diff = color? ? diff.colorized_diff : diff.diff
            puts(diff || ['Original source:', original, 'Mutated Source:', current, DIFF_ERROR_MESSAGE])
          end

          # Noop details
          #
          # @return [String]
          #
          # @api private
          #
          def noop_details
            info(NOOP_MESSAGE, failed_test_results.length)
            visit_failed_test_results
          end

          # Neutral details
          #
          # @return [String]
          #
          # @api private
          #
          def neutral_details
            info(NEUTRAL_MESSAGE, mutation.subject.node.inspect, mutation.source, failed_test_results.length)
            visit_failed_test_results
          end

          # Visit failed test results
          #
          # @return [undefined]
          #
          # @api private
          #
          def visit_failed_test_results
            visit_collection(TestResult, failed_test_results)
          end

        end # MutationResult

        # Test result reporter
        class TestResult < self

          delegate :test, :runtime

          # Run test result reporter
          #
          # @return [self]
          #
          # @api private
          #
          def run
            status('- %s / runtime: %s', test.identification, object.runtime)
            puts('Test Output:')
            puts(object.output)
          end

        end # TestResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
