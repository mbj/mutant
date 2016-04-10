module Mutant
  class Isolation
    include AbstractType

    # Call block in isolation
    #
    # @return [Object]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
