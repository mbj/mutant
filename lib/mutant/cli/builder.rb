module Mutant
  class CLI
    # Abstract base class for strategy builders
    class Builder
      include AbstractType

      # Rspec strategy builder
      class Rspec < self

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

        # Add cli options
        #
        # @param [OptionParser] parser
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.add_options(parser)
          builder = new
          parser.on('--rspec', 'kills mutations with rspec') do
            yield builder
          end
          parser.on('--rspec-level LEVEL', 'set rspec expansion level') do |level|
            builder.set_level(level.to_i)
          end
        end

      end # Rspec
    end # Builder
  end # CLI
end # Mutant
