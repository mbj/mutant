# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for required arguments
      class Argument < self
        handle(:arg, :kwarg)

        children :name

      private

        def dispatch; end

        # Mutator for optional arguments
        class Optional < self

          TYPE_MAP = {
            optarg:   :arg,
            kwoptarg: :kwarg
          }.freeze

          handle(:optarg, :kwoptarg)

          children :name, :default

        private

          def dispatch
            emit_required_mutation
            emit_default_mutations
          end

          def emit_required_mutation
            emit(s(TYPE_MAP.fetch(node.type), name))
          end

        end # Optional
      end # Argument
    end # Node
  end # Mutator
end # Mutant
