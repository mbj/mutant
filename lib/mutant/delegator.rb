module Mutant
  module Delegator
    module ClassMethods

    private
      # Create delegators to object
      #
      # @return [undefined]
      #
      # @api private
      #
      def delegate(*names)
        names.each do |name|
          define_delegator(name)
        end
      end

      # Create delegator to object
      #
      # @param [Symbol] name
      #
      # @return [undefined]
      #
      # @api private
      #
      def define_delegator(name)
        define_method(name) do
          object.public_send(name)
        end
        private name
      end

    end # ClassMethods

    # Hook called when module is included
    #
    # @param [Class,Module] host
    #
    # @api private
    #
    def self.included(host)
      super
      host.class_eval do
        extend ClassMethods
      end
    end

  end # Delegator
end # Mutant
