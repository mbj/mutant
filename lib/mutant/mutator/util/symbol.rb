# encoding: utf-8

module Mutant
  class Mutator
    class Util

      # Utility symbol mutator
      class Symbol < self

        handle(::Symbol)

        POSTFIX = '__mutant__'.freeze

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit((input.to_s + POSTFIX).to_sym)
        end

      end # Symbol
    end # Util
  end # Mutator
end # Mutant
