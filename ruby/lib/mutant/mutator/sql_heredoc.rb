# frozen_string_literal: true

module Mutant
  class Mutator
    # Detection and mutation of SQL heredoc bodies
    #
    # Handles both node shapes a heredoc can take:
    #  * a single-line body parses to a +:str+ node whose sole child is the
    #    whole SQL text;
    #  * a multi-line body parses to a +:dstr+ node whose children are one
    #    +:str+ per line.
    #
    # Each mutation flips a single SQL keyword, so the mutated text keeps the
    # same line boundaries as the original and the node can be rebuilt with the
    # original shape.
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

        Mutant::Mutator::Sql.mutate(body(node)).each_with_object(Set.new) do |mutated, set|
          set << rebuild(node, mutated)
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

      # The complete SQL text of a +:str+ or +:dstr+ heredoc
      #
      # @param [Parser::AST::Node] node
      #
      # @return [String]
      def self.body(node)
        return node.children.first if node.type.equal?(:str)

        node.children
            .select { |child| child.type.equal?(:str) }
            .map { |child| child.children.first }
            .join
      end
      private_class_method :body

      # Rebuild a heredoc node with the same shape as +node+ from mutated text
      #
      # Keyword flips never cross line boundaries, so the mutated text splits
      # into exactly as many lines as the original +:dstr+.
      #
      # @param [Parser::AST::Node] node
      # @param [String] text
      #
      # @return [Parser::AST::Node]
      def self.rebuild(node, text)
        return ::Parser::AST::Node.new(:str, [text]) if node.type.equal?(:str)

        ::Parser::AST::Node.new(
          :dstr,
          text.lines.map { |line| ::Parser::AST::Node.new(:str, [line]) }
        )
      end
      private_class_method :rebuild
    end # SqlHeredoc
  end # Mutator
end # Mutant
