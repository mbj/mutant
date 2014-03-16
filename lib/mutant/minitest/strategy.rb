# encoding: utf-8

module Mutant
  module Minitest
    # Rspec killer strategy
    class Strategy < Mutant::Strategy

      register 'minitest'

      KILLER = Killer::Forking.new(Minitest::Killer)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        ENV['MUTANT'] = '1'
        Pathname.glob(Pathname.new('.').join('test/**/*_test.rb')) do |path|
          require "./#{path}"
        end
        self
      end
      memoize :setup

    end # Strategy
  end # Rspec
end # Mutant
