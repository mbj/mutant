module Mutant
  # Mixin for defining a `failure?` predicate that inverts a concrete `success?` method
  module FailurePredicate
    # Inversion of `success?` method
    #
    # @return [Object]
    def failure?
      !success?
    end
  end
end
