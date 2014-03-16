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
        self
      end
      memoize :setup


    end # Strategy
  end # Rspec
end # Mutant
