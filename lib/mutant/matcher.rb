module Mutant
  # Abstract matcher to find ASTs to mutate
  class Matcher
    include Enumerable

    # Enumerate mutatees
    #
    # @api private
    #
    # @return [undefined]
    #
    def each
      Mutant.not_implemented(self)
    end

  private

  end
end
