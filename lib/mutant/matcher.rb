module Mutant
  # Abstract matcher to find ASTs to mutate
  class Matcher
    include Enumerable, Abstract

    # Enumerate subjects
    #
    # @api private
    #
    # @return [undefined]
    #
    abstract_method :each

  private

  end
end
