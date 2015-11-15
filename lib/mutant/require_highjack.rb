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
      target.method(:require).tap do
        target.module_eval do
          define_method(:require, &callback)
          public :require
        end
      end
    end

  end # RequireHighjack
end # Mutant
