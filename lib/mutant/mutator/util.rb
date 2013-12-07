# encoding: utf-8

module Mutant
  class Mutator
    # Namespace for utility mutators
    class Util < self

      # Run ulitity mutator
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
      #
      def self.each(input, parent, &block)
        return to_enum(__method__, input, parent) unless block_given?

        context = Context.new(Config.new({}), parent, input)

        new(context, block)

        self
      end

    private

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

    end # Util
  end # Mutator
end # Mutant
