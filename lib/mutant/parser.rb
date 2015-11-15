module Mutant
  # An AST Parser
  class Parser
    include Adamantium::Mutable, Equalizer.new

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    def initialize
      @cache = {}
    end

    # Parse path into AST
    #
    # @param [Pathname] path
    #
    # @return [AST::Node]
    #
    # @api private
    def call(path)
      @cache[path] ||= ::Parser::CurrentRuby.parse(path.read)
    end

  end # Parser
end # Mutant
