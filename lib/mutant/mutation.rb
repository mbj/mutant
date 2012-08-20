module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include Immutable

    # Return mutation subject
    #
    # @return [Subject]
    #
    # @api private
    #
    def subject; @subject; end

    # Return mutated root node
    #
    # @return [Rubinius::AST::Script]
    #
    # @api private
    #
    def root
      subject.root(@node)
    end
    memoize :root

    # Insert mutated node
    #
    # @return [self]
    #
    # @api private
    #
    def insert
      Loader.run(root)
      self
    end

    # Return identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{subject.identification}:#{sha1[0..4]}"
    end

    # Return sha1 sum of source
    #
    # @return [String]
    #
    # @api private
    #
    def sha1
      SHA1.hexdigest(source)
    end
    memoize :sha1

    # Return source
    #
    # @return [String]
    #
    # @api private
    #
    def source
      ToSource.to_source(@node)
    end
    memoize :source

    # Return original source
    #
    # @return [String]
    #
    # @api private
    #
    def original_source
      subject.source
    end

  private

    # Initialize mutation object
    #
    # @param [Subject] subject
    # @param [Rubinius::Node::AST] node
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(subject, node)
      @subject, @node = subject, node
    end
  end
end
