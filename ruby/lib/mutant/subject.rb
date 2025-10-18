# frozen_string_literal: true

module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium, Enumerable
    include Anima.new(:config, :context, :node)

    # Mutations for this subject
    #
    # @return [Enumerable<Mutation>]
    # @return [undefined]
    #
    # mutant:disable
    # rubocop:disable Metrics/MethodLength
    def mutations
      [neutral_mutation].concat(
        Mutator::Node.mutate(
          config: config.mutation,
          node:
        ).each_with_object([]) do |mutant, aggregate|
          Mutation::Evil
            .from_node(subject: self, node: wrap_node(mutant))
            .either(
              ->(validation) {},
              aggregate.public_method(:<<)
            )
        end
      )
    end
    memoize :mutations

    def inline_disabled?
      config.inline_disable
    end

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

    # Perform post insert cleanup
    #
    # @return [self]
    def post_insert
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

    def neutral_mutation
      Mutation::Neutral
        .from_node(subject: self, node: wrap_node(node))
        .from_right
    end

    def wrap_node(node)
      node
    end

  end # Subject
end # Mutant
