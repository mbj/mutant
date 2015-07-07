module Mutant
  class Mutator
    # Namespace for utility mutators
    class Util < self

      # Run utility mutator
      #
      # @param [Object] object
      # @param [Object] parent
      #
      # @return [Enumerator<Object>]
      #   if no block given
      #
      # @return [self]
      #   otherwise
      #
      # @api private
      def self.each(object, parent, &block)
        return to_enum(__method__, object, parent) unless block_given?

        new(object, parent, block)

        self
      end

    private

      # Test if mutation is new
      #
      # @param [Object] generated
      #
      # @return [Boolean]
      #
      # @api private
      def new?(generated)
        !input.eql?(generated)
      end

    end # Util
  end # Mutator
end # Mutant
