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
        args = command_line_arguments
        begin
          !::RSpec::Core::Runner.run(args, null, null).zero?
        rescue StandardError
          true
        end
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

    end # Rspec
  end # Killer
end # Mutant
