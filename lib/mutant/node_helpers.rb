module Mutant
  # Mixin for node helpers
  module NodeHelpers

    # Build node
    #
    # @param [Symbol] type
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end
    module_function :s


    NAN               = s(:send, s(:float,  0.0), :/, s(:args, s(:float, 0.0)))
    NEGATIVE_INFINITY = s(:send, s(:float, -1.0), :/, s(:args, s(:float, 0.0)))
    INFINITY          = s(:send, s(:float,  1.0), :/, s(:args, s(:float, 0.0)))
    NEW_OBJECT        = s(:send, s(:const, s(:cbase), :Object), :new)

    RAISE             = s(:send, nil, :raise)

    N_NIL             = s(:nil)
    N_TRUE            = s(:true)
    N_FALSE           = s(:false)
    N_EMPTY           = s(:empty)

  end # NodeHelpers
end # Mutant
