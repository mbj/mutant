module Mutant
  # Subject of mutation
  class Subject
    include Adamantium::Flat, Enumerable

    # Return context
    #
    # @return [Context]
    #
    # @api private
    #
    attr_reader :context

    # Return matcher
    #
    # @return [Matcher]
    #
    # @api private
    #
    attr_reader :matcher

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
        yield Mutation.new(self, mutant)
      end

      self
    end

    # Return subject identicication
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      source_path = context.source_path
      source_line = node.line
      "#{matcher.identification}:#{source_path}:#{source_line}"
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

    # Reset subject into original state
    #
    # @return [self]
    #
    # @api private
    #
    def reset
      Loader.run(original_root)
    end

  private

    # Initialize subject
    #
    # @param [Matcher] matcher
    #   the context of mutations
    #
    # @param [Rubinius::AST::Node] node
    #   the node to be mutated
    #
    # @return [unkown]
    #
    # @api private
    #
    def initialize(matcher, context, node)
      @matcher, @context, @node = matcher, context, node
    end

  end
end
