# encoding: utf-8

module Mutant
  module Minitest
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
        ENV['MUTANT'] = '1'
        Pathname.glob(Pathname.new('.').join('test/**/*_test.rb')) do |path|
          require "./#{path}"
        end
        arguments = []
        !MiniTest::Unit.new.run(arguments).zero?
      end

    end # Killer
  end # Minitest
end # Mutant
