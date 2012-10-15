module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include Adamantium, Equalizer.new(:sha1)

    # Return mutation subject
    #
    # @return [Subject]
    #
    # @api private
    #
    def subject; @subject; end

    # Return mutated node
    #
    # @return [Subject]
    #
    # @api private
    #
    def node; @node; end

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
      "#{subject.identification}:#{code}"
    end
    memoize :identification

    # Return mutation code
    #
    # @return [String]
    #
    # @api private
    #
    def code
      sha1[0..4]
    end
    memoize :code

    # Return sha1 sum of source and subject identification
    #
    # @return [String]
    #
    # @api private
    #
    def sha1
      SHA1.hexdigest(subject.identification + source)
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
