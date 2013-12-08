module Mutant
  class Mutator

    # Mutator configuration
    class Config
      include Adamantium, Anima::Update, Anima.new(
        # Yeah I know this is long. If someone could please come up with a more shorter but as narrow name!
        :return_as_last_block_statement_value_propagation
      )

      DEFAULT = new(
        return_as_last_block_statement_value_propagation: true
      )

    end # Config
  end # Mutator

end # Mutant
