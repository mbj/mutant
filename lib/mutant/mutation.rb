module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat
    include Concord::Public.new(:subject, :node)

    CODE_DELIMITER = "\0".freeze
    CODE_RANGE     = (0..4).freeze

    # Return mutated root node
    #
    # @return [Parser::AST::Node]
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
    # @return [Boolean]
    #
    # @api private
    #
    abstract_method :success?

    # Insert mutated node
    #
    # FIXME: Cache subject visibility in a better way! Ideally dont mutate it
    #   implicitly. Also subject.public? should NOT be a public interface it
    #   is a detail of method mutations.
    #
    # @return [self]
    #
    # @api private
    #
    def insert
      subject.public?
      Loader::Eval.call(root, subject)
      self
    end

    # Return identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{self.class::SYMBOL}:#{subject.identification}:#{code}"
    end
    memoize :identification

    # Return mutation code
    #
    # @return [String]
    #
    # @api private
    #
    def code
      sha1[CODE_RANGE]
    end
    memoize :code

    # Return source
    #
    # @return [String]
    #
    # @api private
    #
    def source
      Unparser.unparse(node)
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

    # Test if test should fail under mutation
    #
    # @return [Boolean]
    #
    # @api private
    #
    def should_fail?
      self.class::SHOULD_FAIL
    end

  private

    # Return sha1 sum of source and subject identification
    #
    # @return [String]
    #
    # @api private
    #
    def sha1
      Digest::SHA1.hexdigest(subject.identification + CODE_DELIMITER + source)
    end
    memoize :sha1

  end # Mutation
end # Mutant
