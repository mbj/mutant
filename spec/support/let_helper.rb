module MutantTest
  module LetHelper

    # Define instance double reflecting let binding name
    #
    # @param [Symbol] name
    # @param [Class] klass
    #
    # @return [undefined]
    #
    # @api private
    #
    def let_instance(name, klass, mappings = [], &block)
      let(name) do
        attributes = Hash[mappings.map { |attribute, method = attribute| [attribute, public_send(method)] }]
        instance_double(
          klass,
          name,
          attributes.merge(block ? instance_exec(&block) : {})
        )
      end
    end

    # Define an anonymous double
    #
    # @param [Symbol] name
    #
    # @return [undeifned]
    #
    # @api private
    #
    def let_anon(name)
      let(name) { double(name) }
    end

  end # LetDoubleHelper
end # MutantTest
