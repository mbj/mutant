module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium::Flat, Enumerable
    include Concord::Public.new(:config, :context, :node)

    # Return mutations
    #
    # @return [Enumerable<Mutation>]
    # @return [undefined]
    #
    # @api private
    #
    def mutations
      mutations = [neutral_mutation]
      generate_mutations(mutations)
      mutations
    end
    memoize :mutations

    # Return source path
    #
    # @return [String]
    #
    # @api private
    #
    def source_path
      context.source_path
    end

    # Return tests for mutation
    #
    # TODO: This logic is now centralized but still fucked.
    #
    # @return [Array<Test>]
    #
    # @api private
    #
    def tests
      match_expressions.each do |match_expression|
        tests = config.integration.all_tests.select do |test|
          match_expression.prefix?(test.expression)
        end
        return tests if tests.any?
      end

      EMPTY_ARRAY
    end
    memoize :tests

    # Prepare the subject for the insertion of mutation
    #
    # @return [self]
    #
    # @api private
    #
    def prepare
      self
    end

    # Return source line
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def source_line
      node.location.expression.line
    end

    # Return subject identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{expression.syntax}:#{source_path}:#{source_line}"
    end
    memoize :identification

    # Return source representation of ast
    #
    # @return [String]
    #
    # @api private
    #
    def source
      Unparser.unparse(node)
    end
    memoize :source

    # Return root AST for node
    #
    # @param [Parser::AST::Node] node
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def root(node)
      context.root(node)
    end

    # Return match expression
    #
    # @return [Expression]
    #
    # @api private
    #
    abstract_method :expression

    # Return match expressions
    #
    # @return [Enumerable<Expression>]
    #
    # @api private
    #
    def match_expressions
      [expression].concat(context.match_expressions)
    end
    memoize :match_expressions

  private

    # Return neutral mutation
    #
    # @return [Mutation::Neutral]
    #
    # @api private
    #
    def neutral_mutation
      Mutation::Neutral.new(self, node)
    end

    # Generate mutations
    #
    # @param [#<<] emitter
    #
    # @return [undefined]
    #
    # @api private
    #
    def generate_mutations(emitter)
      Mutator.each(node) do |mutant|
        emitter << Mutation::Evil.new(self, mutant)
      end
    end

  end # Subject
end # Mutant
