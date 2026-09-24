# frozen_string_literal: true

module Mutant
  class Mutator
    # Detection and mutation of SQL heredoc bodies
    #
    # A SQL heredoc can parse to either a +:str+ node (single-line body) or a
    # +:dstr+ node (multi-line body). The body is handed to {Mutant::Mutator::Sql}
    # — a real pg_query-backed mutator — and each mutated SQL string is wrapped
    # back into a +:str+ node.
    #
    # The mutated node is always a plain +:str+, even for a +:dstr+ original:
    # pg_query's deparser emits a single-line literal string with no Ruby
    # interpolation, so a +:str+ is the faithful representation and keeps
    # unparser happy.
    #
    # Heredocs that interpolate Ruby (a +:dstr+ with non-+:str+ children) are
    # skipped: the interpolated values are not part of the SQL the parser
    # understands, and mutating around them would silently drop them.
    module SqlHeredoc
      # Pattern to extract the heredoc tag name from expressions like
      # +<<~SQL+, +<<-SQL+, or +<<SQL+.
      HEREDOC_TAG = /<<?-?~?(\w+)/

      # Generate mutations for SQL heredoc bodies
      #
      # @param [Parser::AST::Node] node a +:str+ or +:dstr+ SQL heredoc
      #
      # @return [Set<Parser::AST::Node>]
      def self.mutate(node)
        return Set.new unless sql_heredoc?(node)
        return Set.new if interpolated?(node)

        Mutant::Mutator::Sql.mutate(body(node)).each_with_object(Set.new) do |mutated, set|
          set << rebuild(mutated)
        end
      end

      # Whether the node is a SQL-tagged heredoc
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Boolean]
      def self.sql_heredoc?(node)
        location = node.location or return false
        return false unless location.kind_of?(::Parser::Source::Map::Heredoc)

        HEREDOC_TAG.match(location.expression.source) do |match|
          break match[1].upcase.eql?('SQL')
        end
      end

      class << self
        private

        # The complete SQL text of a +:str+ or +:dstr+ heredoc
        #
        # Only called after {interpolated?} has ruled out non-+:str+ children,
        # so every child of a +:dstr+ is a +:str+ holding one line of the body.
        #
        # @param [Parser::AST::Node] node
        #
        # @return [String]
        def body(node)
          return node.children.first if node.type.equal?(:str)

          node.children.map { |child| child.children.first }.join
        end

        # Wrap a mutated SQL string into a plain +:str+ node
        #
        # @param [String] text
        #
        # @return [Parser::AST::Node]
        def rebuild(text)
          ::Parser::AST::Node.new(:str, [text])
        end

        # Whether the heredoc interpolates Ruby (non-+:str+ children)
        #
        # @param [Parser::AST::Node] node
        #
        # @return [Boolean]
        def interpolated?(node)
          return false if node.type.equal?(:str)

          node.children.any? { |child| !child.type.equal?(:str) }
        end
      end
    end # SqlHeredoc
  end # Mutator
end # Mutant
