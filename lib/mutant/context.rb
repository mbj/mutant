module Mutant
  # An abstract context where mutations can be appied to.
  class Context
    include Adamantium::Flat, AbstractType

    # Return root ast node
    #
    # @return [Rubinis::AST::Script]
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
  end
end
