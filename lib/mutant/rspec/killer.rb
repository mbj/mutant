# encoding: utf-8

module Mutant
  module Rspec
    # Runner for rspec tests
    class Killer < Mutant::Killer

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

        if example_groups.empty?
          $stderr.puts("No rspec example groups found for: #{match_prefixes.join(', ')}")
          return false
        end

        example_groups.each do |group|
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
        match_prefixes.each do |match_expression|
          example_groups = find_with(match_expression)
          return example_groups unless example_groups.empty?
        end

        nil
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

      # Choose and memoize RSpec reporter
      #
      # @return [RSpec::Core::Reporter]
      #
      # @api private
      #
      def reporter
        reporter_class = RSpec::Core::Reporter

        if strategy.rspec2?
          reporter_class.new
        else
          reporter_class.new(strategy.configuration)
        end
      end
      memoize :reporter, freezer: :noop

    end # Killer
  end # Rspec
end # Mutant
