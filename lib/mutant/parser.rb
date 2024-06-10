# frozen_string_literal: true

module Mutant
  # An AST Parser
  class Parser
    include Adamantium, Equalizer.new

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
      @cache[path.expand_path] ||= parse(path.read)
    end

  private

    def parse(source)
      node, comments = Unparser.parse_with_comments(source)

      AST.new(
        node:,
        comment_associations: ::Parser::Source::Comment.associate_by_identity(node, comments)
      )
    end

  end # Parser
end # Mutant
