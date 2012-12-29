module Mutant
  class Mutator
    # Namespace for utility mutators
    class Util < self

      # Run ulitity mutator
      #
      # @param [Object] object
      #
      # @return [Enumerator<Object>]
      #   if no block given
      #
      # @return [self]
      #   otherwise
      #
      # @api private
      #
      def self.each(object, &block)
        return to_enum(__method__, object) unless block_given?

        new(object, block)

        self
      end

      # Test if mutation is new
      #
      # @param [Object] generated
      #
      # @return [true]
      #   if object is new
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def new?(generated)
        input != generated
      end
    end
  end
end
