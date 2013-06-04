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
          util = self.class
          mutate_child(util::ARGUMENTS_INDEX)
          mutate_child(util::BODY_INDEX)
        end

        # Mutator for instance level defines
        class Instance < self

          handle(:def)

          ARGUMENTS_INDEX = 1
          BODY_INDEX      = 2

        end # Instance

        # Mutator for singleton level defines
        class Singleton < self

          handle(:defs)

          ARGUMENTS_INDEX = 2
          BODY_INDEX      = 3

        end # Singelton
      end # Define
    end # Node
  end # Mutator
end # Mutant
