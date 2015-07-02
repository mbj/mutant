module Mutant
  # A simple delegator with opinions
  module Delegator
    # Class level mixins
    module ClassMethods

    private

      # Create delegators to object
      #
      # @return [undefined]
      #
      # @api private
      def delegate(*names)
        names.each(&method(:define_delegator))
      end

      # Create delegator to object
      #
      # @param [Symbol] name
      #
      # @return [undefined]
      #
      # @api private
      def define_delegator(name)
        fail "method #{name} already defined" if instance_methods.include?(name)
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
    # @return [undefined]
    #
    # @api private
    def self.included(host)
      super

      host.extend(ClassMethods)
    end

  end # Delegator
end # Mutant
