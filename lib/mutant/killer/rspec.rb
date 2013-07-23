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
        # Note: we assume the only interesting output from a failed rspec run is stderr.
        require 'stringio'
        rspec_err = StringIO.new

        killed = !::RSpec::Core::Runner.run(command_line_arguments, nil, rspec_err).zero?

        if killed and mutation.should_survive?
          rspec_err.rewind

          puts "#{mutation.class} test failed."
          puts 'RSpec stderr:'
          puts rspec_err.read
        end

        killed
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
