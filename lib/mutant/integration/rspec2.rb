module Mutant
  class Integration
    # Rspec2 integration
    class Rspec2 < Rspec

      register 'rspec'

    private

      # Return options
      #
      # @return [RSpec::Core::ConfigurationOptions]
      #
      # @api private
      #
      def options
        super.tap(&:parse_options)
      end

      # Return full description of example group
      #
      # @param [RSpec::Core::ExampleGroup] example_group
      #
      # @return [String]
      #
      # @api private
      #
      def full_description(example_group)
        example_group.metadata.fetch(:example_group).fetch(:full_description)
      end

      # Return new reporter
      #
      # @param [StringIO] output
      #
      # @return [RSpec::Core::Reporter]
      #
      # @api private
      #
      def new_reporter(output)
        formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)

        RSpec::Core::Reporter.new(formatter)
      end

    end # Rspec2
  end # Integration
end # Mutant
