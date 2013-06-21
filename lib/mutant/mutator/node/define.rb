module Mutant
  class Mutator
    class Node
      # Namespace for define mutations
      class Define < self

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_arguments_mutations
          if body
            emit_body_mutations
          else
            emit_body(NEW_OBJECT)
          end
        end

        # Mutator for instance method defines
        class Instance < self

          handle :def

          children :name, :arguments, :body

        end # Instance

        # Mutator for singleton method defines
        class Singleton < self

          handle :defs

          children :subject, :name, :arguments, :body

        end # Singelton

      end # Define
    end # Node
  end # Mutator
end # Mutant
