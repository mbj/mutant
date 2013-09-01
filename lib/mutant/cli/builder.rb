module Mutant
  class CLI
    # Abstract base class for strategy builders
    class Builder

      # Rspec strategy builder
      class Rspec

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize
          @level = 0
        end

        # Set rspec level
        #
        # @return [self]
        #
        # @api private
        #
        def set_level(level)
          @level = level
          self
        end

        # Return strategy
        #
        # @return [Strategy::Rspec]
        #
        # @api private
        #
        def strategy
          Strategy::Rspec.new(@level)
        end

      end # Rspec
    end # Builder
  end # CLI
end # Mutant
