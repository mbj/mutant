# frozen_string_literal: true

module Mutant
  class AST
    # Singleton nodes
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
      N_EMPTY_ARRAY       = s(:array)
      N_EMPTY_HASH        = s(:hash)
      N_EMPTY_STRING      = s(:str, '')
      N_ZERO_INTEGER      = s(:int, 0)
      N_ZERO_FLOAT        = s(:float, 0.0)

    end # Nodes
  end # AST
end # Mutant
