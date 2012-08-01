module Mutant
  # Abstract matcher to find ASTs to mutate
  class Matcher
    include Enumerable
    extend Abstract

    # Enumerate subjects
    #
    # @api private
    #
    # @return [undefined]
    #
    abstract :each

  private

  end
end
