module Mutant
  # Require highjack
  class RequireHighjack
    include Concord.new(:target, :callback)

    # Return original method
    #
    # @return [#call]
    #
    # @api private
    #
    attr_reader :original

    # Run block with highjacked require
    #
    # @return [self]
    #
    # @api private
    #
    def run
      infect
      yield
      self
    ensure
      disinfect
    end

    # Infect kernel with highjack
    #
    # @return [self]
    #
    # @api private
    #
    def infect
      callback = @callback
      @original = target.method(:require)
      target.module_eval do
        undef :require
        define_method(:require) do |logical_name|
          callback.call(logical_name)
        end
        module_function :require
      end
    end

    # Imperfectly disinfect kernel from highjack
    #
    # @return [self]
    #
    # @api private
    #
    def disinfect
      original = @original
      target.module_eval do
        undef :require
        define_method(:require) do |logical_name|
          original.call(logical_name)
        end
        module_function :require
      end
    end

  end # RequireHighjack
end # Mutant
