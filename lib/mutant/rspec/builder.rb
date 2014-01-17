module Mutant
  module Rspec
    # Rspec strategy builder
    class Builder < CLI::Builder

      register :@strategy

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        @rspec = false
        super
      end

      # Return strategy
      #
      # @return [Strategy::Rspec]
      #
      # @api private
      #
      def output
        unless @rspec
          raise Error, 'No strategy given'
        end

        Strategy.new
      end

    private

      # Add cli options
      #
      # @param [OptionParser] parser
      #
      # @return [undefined]
      #
      # @api private
      #
      def add_options
        parser.on('--rspec', 'kills mutations with rspec') do
          @rspec = true
        end
      end

    end # Builder
  end # Rspec
end # Mutant
