module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium::Flat, AbstractType

    # Call matcher
    #
    # @param [Env::Bootstrap] env
    #
    # @return [Enumerable<Subject>]
    #
    abstract_method :call

  end # Matcher
end # Mutant
