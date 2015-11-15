module Mutant
  # An abstract context where mutations can be applied to.
  class Context
    include Adamantium::Flat, AbstractType, Concord::Public.new(:source_path)

    # Root ast node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Parser::AST::Node]
    abstract_method :root

    # Identification string
    #
    # @return [String]
    abstract_method :identification

  end # Context
end # Mutant
