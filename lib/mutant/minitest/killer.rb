# encoding: utf-8

module Mutant
  module Minitest
    # Runner for rspec tests
    class Killer < Mutant::Killer

      RUNNER = Class.new do
        # Fake null API of mintest runners
        #
        # @return [undefined]
        #
        # @api private
        #
        def record(*arguments)
        end

        # Fake null API of mintest runners
        #
        # @return [undefined]
        #
        # @api private
        #
        def puke(*)
        end

        # Fake null API of mintest runners
        #
        # @return [undefined]
        #
        # @api private
        #
        def info_signal(*)
        end
      end.new

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
        strategy.test_provider.call(subject).any? do |test|
          test.run(RUNNER)
          !test.passed?
        end
      end

    end # Killer
  end # Minitest
end # Mutant
