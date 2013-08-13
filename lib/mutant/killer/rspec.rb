# encoding: utf-8

module Mutant
  class Killer
    # Runner for rspec tests
    class Rspec < self

    # Reporter for mutations that *should* survive
    #
    # @note This works by dumping output on STDERR from the child processes that
    #   runs the rspecs, so its output can't neatly be merged with what's sent
    #   to Mutant::Reporter::CLI::Printer.
    class SurvivorReporter < RSpec::Core::Formatters::BaseTextFormatter
      def initialize
        super($stderr)
      end

      def example_failed(*)
        super
        message("\nTest suite unexpectedly failed:")
        dump_failures
        message("\n")
      end
    end

    # Reporter that discards all rspec events.
    class NullReporter < RSpec::Core::Reporter; end

    private

      # Run rspec test
      #
      # @return [true]
      #   when test is NOT successful
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def run
        mutation.insert

        groups = example_groups

        unless groups
          $stderr.puts "No rspec example groups found for: #{match_prefixes.join(', ')}"
          return false
        end

        reporter = if mutation.should_survive?
          SurvivorReporter.new
        else
          NullReporter.new
        end

        groups.each do |group|
          return true unless group.run(reporter)
        end

        false
      end

      # Return match prefixes
      #
      # @return [Enumerble<String>]
      #
      # @api private
      #
      def match_prefixes
        subject.match_prefixes
      end

      # Return example groups
      #
      # @return [Array<RSpec::Example>]
      #
      # @api private
      #
      def example_groups
        match_prefixes.flat_map { |prefix| find_with(prefix) }.compact.uniq
      end

      # Return example groups that match expression
      #
      # @param [String] match_expression
      #
      # @return [Enumerable<String>]
      #
      # @api private
      #
      def find_with(match_expression)
        all_example_groups.select do |example_group|
          example_group.description.start_with?(match_expression)
        end
      end

      # Return all example groups
      #
      # @return [Enumerable<RSpec::Example>]
      #
      # @api private
      #
      def all_example_groups
        strategy.example_groups
      end

    end # Rspec
  end # Killer
end # Mutant
