module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium::Flat, Enumerable, Concord::Public.new(:context, :node)

    # Enumerate possible mutations
    #
    # @return [self]
    #   returns self if block given
    #
    # @return [Enumerator<Mutation>]
    #   returns eumerator if no block given
    #
    # @api private
    #
    def each
      return to_enum unless block_given?

      yield noop_mutation

      mutations.each do |mutation|
        yield mutation
      end

      self
    end

    # Return noop mutation
    #
    # @return [Mutation::Noop]
    #
    # @api private
    #
    def noop
      Mutation::Neutral.new(self, node)
    end
    memoize :noop

    # Return source path
    #
    # @return [String]
    #
    # @api private
    #
    def source_path
      context.source_path
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
      "#{subtype}:#{source_path}:#{source_line}"
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

  private

    # Return subtype identifier
    #
    # @return [String]
    #
    # @api private
    #
    abstract_method :subtype
    private :subtype

    # Return neutral mutation
    #
    # @return [Mutation::Neutral]
    #
    # @api private
    #
    def noop_mutation
      Mutation::Neutral::Noop.new(self, node)
    end

  end # Subject
end # Mutant
