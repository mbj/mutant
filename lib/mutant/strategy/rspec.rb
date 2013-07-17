module Mutant
  class Strategy
    # Rspec killer strategy
    class Rspec < self

      KILLER = Killer::Forking.new(Killer::Rspec)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def self.setup
        self
      end

    end # Rspec
  end # Strategy
end # Mutant
