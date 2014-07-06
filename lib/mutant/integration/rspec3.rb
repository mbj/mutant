module Mutant
  class Integration
    # Rspec3 integration
    class Rspec3 < Rspec

      register 'rspec'

    private

      # Return full description for example group
      #
      # @param [RSpec::Core::ExampleGroup] example_group
      #
      # @return [String]
      #
      # @api private
      #
      def full_description(example_group)
        example_group.metadata.fetch(:full_description)
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
        notifications = RSpec::Core::Formatters::Loader.allocate.send(:notifications_for, formatter.class)

        RSpec::Core::Reporter.new(configuration).tap do |reporter|
          reporter.register_listener(formatter, *notifications)
        end
      end

    end # Rspec3
  end # Integration
end # Mutant
