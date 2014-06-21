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

    N_NAN               = s(:send, s(:float,  0.0), :/, s(:float, 0.0))
    N_INFINITY          = s(:send, s(:float,  1.0), :/, s(:float, 0.0))
    N_NEGATIVE_INFINITY = s(:send, s(:float, -1.0), :/, s(:float, 0.0))
    N_RAISE             = s(:send, nil, :raise)
    N_TRUE              = s(:true)
    N_FALSE             = s(:false)
    N_NIL               = s(:nil)
    N_EMPTY             = s(:empty)
    N_SELF              = s(:self)

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

    NODE_TYPES.each do |type|
      fail "method: #{type} is already defined" if instance_methods(true).include?(type)

      name = "n_#{type.to_s.sub(/\??\z/, '?')}"

      define_method(name) do |node|
        node.type.equal?(type)
      end
      private name
    end

  end # NodeHelpers
end # Mutant
