module Mutant

  # Walker for all ast nodes
  class Walker

    # Run walkter
    #
    # @param [Parser::AST::Node] root
    #
    # @return [self]
    #
    # @api private
    #
    def self.run(root, &block)
      new(root, block)
      self
    end

    private_class_method :new

    # Initialize and run walker
    #
    # @param [Parser::AST::Node] root
    # @param [#call(node)] block
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(root, block)
      @root, @block = root, block
      dispatch(root)
    end

  private

    # Perform dispatch
    #
    # @param [Parser::AST::Node] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def dispatch(node)
      @block.call(node)
      node.children.grep(Parser::AST::Node).each(&method(:dispatch))
    end
  end # Walker

end # Mutant
