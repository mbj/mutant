# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Mutator for required arguments
      class Argument < self
        handle(:arg)

        UNDERSCORE = '_'.freeze

        children :name

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_name_mutation
        end

        # Emit name mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_name_mutation
          return if skip?
          Mutator::Util::Symbol.each(name, self) do |name|
            emit_name(name)
          end
        end

        # Test if argument mutation is skipped
        #
        # @return [true]
        #   if argument should not get mutated
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def skip?
          name.to_s.start_with?(UNDERSCORE)
        end

        # Mutator for optional arguments
        class Optional < self

          handle(:optarg)

          children :name, :default

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_name_mutation
            emit_required_mutation
            emit_default_mutations
          end

          # Emit required mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_required_mutation
            emit(s(:arg, name))
          end

        end # Optional

      end # Argument
    end # Node
  end # Mutator
end # Mutant
