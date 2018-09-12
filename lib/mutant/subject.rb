# frozen_string_literal: true

module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium::Flat, Enumerable
    include Concord::Public.new(:context, :node)

    # Mutations for this subject
    #
    # @return [Enumerable<Mutation>]
    # @return [undefined]
    def mutations
      [neutral_mutation].concat(
        Mutator.mutate(node).map do |mutant|
          Mutation::Evil.new(self, wrap_node(mutant))
        end
      )
    end
    memoize :mutations

    # Source path
    #
    # @return [Pathname]
    def source_path
      context.source_path
    end

    # Prepare subject for insertion of mutation
    #
    # @return [self]
    def prepare
      self
    end

    # Source line range
    #
    # @return [Range<Integer>]
    def source_lines
      expression = node.location.expression
      expression.line..expression.source_buffer.decompose_position(expression.end_pos).first
    end
    memoize :source_lines

    # First source line
    #
    # @return [Integer]
    def source_line
      source_lines.begin
    end

    # Identification string
    #
    # @return [String]
    def identification
      "#{expression.syntax}:#{source_path}:#{source_line}"
    end
    memoize :identification

    # Source representation of AST
    #
    # @return [String]
    def source
      Unparser.unparse(wrap_node(node))
    end
    memoize :source

    # Match expression
    #
    # @return [Expression]
    abstract_method :expression

    # Match expressions
    #
    # @return [Enumerable<Expression>]
    abstract_method :match_expressions

  private

    # Neutral mutation
    #
    # @return [Mutation::Neutral]
    def neutral_mutation
      Mutation::Neutral.new(self, wrap_node(node))
    end

    # Wrap node into subject specific container
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Parser::AST::Node]
    def wrap_node(node)
      node
    end

  end # Subject
end # Mutant
