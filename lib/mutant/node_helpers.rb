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

  end # NodeHelpers
end # Mutant
