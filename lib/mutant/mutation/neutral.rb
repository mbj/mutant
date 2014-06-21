module Mutant
  class Mutation
    # Neutral mutation
    class Neutral < self

      SYMBOL      = 'neutral'.freeze
      SHOULD_FAIL = false

      # Noop mutation, special case of neutral
      class Noop < self

        SYMBOL = 'noop'.freeze

      end # Noop

    end # Neutral
  end # Mutation
end # Mutant
