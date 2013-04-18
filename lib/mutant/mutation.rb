module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat, Equalizer.new(:sha1)

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

    # Return mutation subject
    #
    # @return [Subject]
    #
    # @api private
    #
    attr_reader :subject

    # Return mutated node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    attr_reader :node

    # Return mutated root node
    #
    # @return [Rubinius::AST::Node]
    #
    # @api private
    #
    def root
      subject.root(node)
    end
    memoize :root

    # Test if killer is successful
    #
    # @param [Killer] killer
    #
    # @return [true]
    #   if killer is successful
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    abstract_method :success?

    # Insert mutated node
    #
    # @return [self]
    #
    # @api private
    #
    def insert
      Loader::Eval.run(root, subject)
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
      Digest::SHA1.hexdigest(subject.identification + 0.chr + source)
    end
    memoize :sha1

    # Return source
    #
    # @return [String]
    #
    # @api private
    #
    def source
      ToSource.to_source(node)
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

  end
end
