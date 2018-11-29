# frozen_string_literal: true

module Mutant
  # An AST Parser
  class Parser
    include Adamantium::Mutable, Equalizer.new

    # Initialize object
    #
    # @return [undefined]
    def initialize
      @cache = {}
    end

    # Parse path into AST
    #
    # @param [Pathname] path
    #
    # @return [AST::Node]
    def call(path)
      @cache[path] ||= Unparser.parse(path.read)
    end

  end # Parser
end # Mutant
