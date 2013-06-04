module Mutant
  class Mutator
    class Util

      # Mutators that mutates symbol inputs
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
