module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium::Flat, Enumerable
    include Concord::Public.new(:context, :node)

    # Return mutations
    #
    # @return [Enumerable<Mutation>]
    #
    # @api private
    #
    def mutations
      mutations = []
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

    # Return root AST node for original AST ndoe
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def original_root
      root(node)
    end
    memoize :original_root

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
    def noop_mutation
      Mutation::Neutral::Noop.new(self, node)
    end

    # Generate mutations
    #
    # @param [#<<] emitter
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :generate_mutations

  end # Subject
end # Mutant
