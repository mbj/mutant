# encoding: utf-8

module Mutant
  module Rspec
    # Rspec killer strategy
    class Strategy < Mutant::Strategy

      register 'rspec'

      KILLER = Killer::Forking.new(Rspec::Killer)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        output = StringIO.new
        configuration.error_stream = output
        configuration.output_stream = output
        options.configure(configuration)
        configuration.load_spec_files
        self
      end
      memoize :setup

      # Return configuration
      #
      # @return [RSpec::Core::Configuration]
      #
      # @api private
      #
      def configuration
        RSpec::Core::Configuration.new
      end
      memoize :configuration, freezer: :noop

      # Return example groups
      #
      # @return [Enumerable<RSpec::Core::ExampleGroup>]
      #
      # @api private
      #
      def example_groups
        world.example_groups
      end

      # Detect RSpec 2
      #
      # @return [true]
      #   when RSpec 2
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def rspec2?
        RSpec::Core::Version::STRING.start_with?('2.')
      end

    private

      # Return world
      #
      # @return [RSpec::Core::World]
      #
      # @api private
      #
      def world
        RSpec.world
      end
      memoize :world, freezer: :noop

      # Return options
      #
      # @return [RSpec::Core::ConfigurationOptions]
      #
      # @api private
      #
      def options
        options = RSpec::Core::ConfigurationOptions.new(%w(--fail-fast spec))
        options.parse_options if rspec2?
        options
      end
      memoize :options, freezer: :noop

    end # Strategy
  end # Rspec
end # Mutant
