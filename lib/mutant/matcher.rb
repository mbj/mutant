module Mutant
  # Abstract filter for rubinius asts.
  class Matcher
    include Enumerable

    # Return each matched node
    #
    # @api private
    #
    # @return [undefined]
    #
    def each
      Mutant.not_implemented(self)
    end
  end
end
