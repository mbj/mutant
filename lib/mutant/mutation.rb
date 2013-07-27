module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat, Concord::Public.new(:subject, :node)

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
    # @return [true]
    #   if killer is successful
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    abstract_method :success?

    # Indicate if a killer should treat a kill as problematic
    #
    # @return [true]
    #   if killing is unexpected
    #
    # @return [false]
    #   if killing is expected
    #
    # @api private
    #
    abstract_method :should_survive?

    # Insert mutated node
    #
    # FIXME:
    #   Cache subject visibility in a better way! Ideally dont mutate it implicitly.
    #   Also subject.public? should NOT be a public interface it is a detail of method
    #   mutations.
    #
    # @return [self]
    #
    # @api private
    #
    def insert
      subject.public?
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

  end # Mutation
end # Mutant
