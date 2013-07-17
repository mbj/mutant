module Mutant
  class Strategy
    # Rspec killer strategy
    class Rspec < self
      include Equalizer.new

      KILLER = Killer::Forking.new(Killer::Rspec)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        self
      end

    end # Rspec
  end # Strategy
end # Mutant
