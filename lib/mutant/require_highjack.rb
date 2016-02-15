module Mutant
  # Require highjack
  module RequireHighjack

    # Install require callback
    #
    # @param [Module] target
    # @param [#call] callback
    #
    # @return [#call]
    #   the original implementation on singleton
    def self.call(target, callback)
      target.public_method(:require).tap do
        target.module_eval do
          undef_method(:require)
          define_method(:require, &callback)
          class << self
            undef_method(:require)
          end
          define_singleton_method(:require, &callback)
        end
      end
    end

  end # RequireHighjack
end # Mutant
