module Mutant
  # Class or Module bound to an exact expression
  class Scope
    include Concord::Public.new(:raw, :expression)
  end # Scope
end # Mutant
