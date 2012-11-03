module Mutant
  # An abstract context where mutations can be appied to.
  class Context
    include Adamantium::Flat, AbstractClass

    # Return root ast node
    #
    # @param [Rubinius::AST::Node] node
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

    # Return script node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [Rubinius::AST::Script]
    #
    # @api private
    #
    def script(node)
      Rubinius::AST::Script.new(node).tap do |script|
        script.file = source_path
      end
    end
  end
end
