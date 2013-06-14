module Mutant
  # An abstract context where mutations can be appied to.
  class Context
    include Adamantium::Flat, AbstractType

    # Return root ast node
    #
    # @param [Rubnius::AST::Node] node
    #
    # @return [Rubinis::AST::Node]
    #
    # @api private
    #
    abstract_method :root

    # Return source path
    #
    # @return [String]
    #
    # @api private
    #
    attr_reader :source_path

    # Return identification
    #
    # @return [String]
    #
    # @api private
    #
    abstract_method :identification

  private

    # Initialize context
    #
    # @param [String] source_path
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(source_path)
      @source_path = source_path
    end
  end # Context
end # Mutant
