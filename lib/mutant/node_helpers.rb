# encoding: utf-8

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

    NAN =
      s(:begin, s(:send, s(:float,  0.0), :/, s(:args, s(:float, 0.0))))
    INFINITY =
      s(:begin, s(:send, s(:float,  1.0), :/, s(:args, s(:float, 0.0))))
    NEW_OBJECT =
      s(:send, s(:const, s(:cbase), :Object), :new)
    NEGATIVE_INFINITY =
      s(:begin, s(:send, s(:float, -1.0), :/, s(:args, s(:float, 0.0))))

    RAISE             = s(:send, nil, :raise)

    N_TRUE            = s(:true)
    N_FALSE           = s(:false)
    N_NIL             = s(:nil)
    N_EMPTY           = s(:empty)

    # Build a negated boolean node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def n_not(node)
      s(:send, node, :!)
    end

  end # NodeHelpers
end # Mutant
