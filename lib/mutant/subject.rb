module Mutant
  # Subject of a mutation
  class Subject
    include AbstractType, Adamantium::Flat, Enumerable, Equalizer.new(:context, :node)

    # Return context
    #
    # @return [Context]
    #
    # @api private
    #
    attr_reader :context

    # Return AST node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    attr_reader :node

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
      Mutator.each(node) do |mutant|
        yield Mutation::Evil.new(self, mutant)
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
      node.line
    end

    # Return subject identicication
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
    # @return [Source]
    #
    # @api private
    # 
    def source
      ToSource.to_source(node)
    end
    memoize :source

    # Return root AST for node
    #
    # @param [Rubinius::AST::Node] node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    def root(node)
      context.root(node)
    end

    # Return root AST node for original AST ndoe
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    def original_root
      root(node)
    end
    memoize :original_root

  private

    # Initialize subject
    #
    # @param [Mutant::Context] context
    #
    # @param [Rubinius::AST::Node] node
    #   the original node to be mutated
    #
    # @return [unkown]
    #
    # @api private
    #
    def initialize(context, node)
      @context, @node = context, node
    end

    # Return subtype identifier
    #
    # @return [String]
    #
    # @api private
    #
    abstract_method :subtype
    private :subtype

  end
end
