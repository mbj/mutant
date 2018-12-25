# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for required arguments
      class Argument < self
        handle(:arg, :kwarg)

        UNDERSCORE = '_'

        children :name

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_name_mutation
        end

        # Emit name mutations
        #
        # @return [undefined]
        def emit_name_mutation
          return if skip?
          emit_name(:"#{UNDERSCORE}#{name}")
        end

        # Test if argument mutation is skipped
        #
        # @return [Boolean]
        def skip?
          name.to_s.start_with?(UNDERSCORE)
        end

        # Mutator for optional arguments
        class Optional < self

          TYPE_MAP = IceNine.deep_freeze(
            optarg:   :arg,
            kwoptarg: :kwarg
          )

          handle(:optarg, :kwoptarg)

          children :name, :default

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_name_mutation
            emit_required_mutation
            emit_default_mutations
          end

          # Emit required mutation
          #
          # @return [undefined]
          def emit_required_mutation
            emit(s(TYPE_MAP.fetch(node.type), name))
          end

        end # Optional
      end # Argument
    end # Node
  end # Mutator
end # Mutant
