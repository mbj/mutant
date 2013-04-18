module Mutant
  class Killer
    # Runner for rspec tests
    class Rspec < self

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
        # TODO: replace with real streams from configuration
        require 'stringio'
        null = StringIO.new
        !::RSpec::Core::Runner.run(command_line_arguments, null, null).zero?
      end

      # Return command line arguments
      #
      # @return [Array]
      #
      # @api private
      #
      def command_line_arguments
        %W(
          --fail-fast
        ) + strategy.spec_files(mutation.subject)
      end

    end
  end
end
