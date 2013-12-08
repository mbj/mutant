module Mutant
  class Mutator

    # Mutator configuration
    class Config
      include Adamantium, Anima.new(
        :return_as_last_statement_elimination
      )

      DEFAULT = new(
        return_as_last_statement_elimination: true
      )

    end # Config
  end # Mutator

end # Mutant
