module Mutant
  class Mutator
    class Util

      # Utility symbol mutator
      class Symbol < self

        POSTFIX = '__mutant__'.freeze

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit((input.to_s + POSTFIX).to_sym)
        end

      end # Symbol
    end # Util
  end # Mutator
end # Mutant
