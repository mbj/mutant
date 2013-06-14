module Mutant
  class Mutator
    class Util

      # Utility symbol mutator
      class Symbol < self

        handle(::Symbol)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_new { :"s#{Random.hex_string}" }
        end

      end # Symbol
    end # Util
  end # Mutator
end # Mutant
