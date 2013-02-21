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

      # Return expanded name
      #
      # @param [Symbol] name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def self.expand(name)
        METHOD_NAME_EXPANSIONS.inject(name.to_s) do |name, find_replace|
          name.gsub(*find_replace)
        end.to_sym
      end
      private_class_method :expand

    end
  end
end
