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
          emit_new { :"s#{Random.hex_string}" } unless ignore?
        end

        # Test if symbol is ignored
        #
        # @return [true]
        #   if symbol begins with an underscore
        #
        # @return [false]
        #   otherwise
        #
        # @pai private
        #
        def ignore?
          input.to_s[0] == '_'
        end

      end
    end
  end
end
