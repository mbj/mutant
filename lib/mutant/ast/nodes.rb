module Mutant
  module AST
    # Singleton nodes
    #
    # :reek:TooManyConstants
    module Nodes
      extend Sexp

      N_NAN               = s(:send, s(:float,  0.0), :/, s(:float, 0.0))
      N_INFINITY          = s(:send, s(:float,  1.0), :/, s(:float, 0.0))
      N_NEGATIVE_INFINITY = s(:send, s(:float, -1.0), :/, s(:float, 0.0))
      N_RAISE             = s(:send, nil, :raise)
      N_TRUE              = s(:true)
      N_FALSE             = s(:false)
      N_NIL               = s(:nil)
      N_EMPTY             = s(:empty)
      N_SELF              = s(:self)
      N_ZSUPER            = s(:zsuper)
      N_EMPTY_SUPER       = s(:super)

    end # Nodes
  end # AST
end # Mutant
