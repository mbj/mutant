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

    # Test if mutation is killed by test report
    #
    # @param [Report::Test] test_report
    #
    # @return [Boolean]
    #
    # @api private
    #
    def killed_by?(test_report)
      self.class::SHOULD_PASS.equal?(test_report.passed)
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

    # Evil mutation that should case mutations to fail tests
    class Evil < self

      SHOULD_PASS = false
      SYMBOL      = 'evil'.freeze

    end # Evil

    # Neutral mutation that should not cause mutations to fail tests
    class Neutral < self

      SYMBOL      = 'neutral'.freeze
      SHOULD_PASS = true

    end # Neutral

    # Noop mutation, special case of neutral
    class Noop < self

      SYMBOL      = 'noop'.freeze
      SHOULD_PASS = true

    end # Noop

  end # Mutation
end # Mutant
