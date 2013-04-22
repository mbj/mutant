module Mutant
  class Strategy
    module MethodExpansion

      # Run method name expansion
      #
      # @param [Symbol] name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def self.run(name)
        name = map(name) || expand(name)
      end

      # Return mapped name
      #
      # @param [Symbol] name
      #
      # @return [Symbol]
      #   if name was mapped
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.map(name)
        OPERATOR_EXPANSIONS[name]
      end
      private_class_method :map

      REGEXP = /#{Regexp.union(*METHOD_POSTFIX_EXPANSIONS.keys)}\z/.freeze

      # Return expanded name
      #
      # @param [Symbol] name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def self.expand(name)
        name.to_s.gsub(REGEXP, METHOD_POSTFIX_EXPANSIONS).to_sym
      end
      private_class_method :expand

    end
  end
end
