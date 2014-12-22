module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat
    include Concord::Public.new(:subject, :node)

    CODE_DELIMITER = "\0".freeze
    CODE_RANGE     = (0..4).freeze

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

    # Test if mutation is killed by test reports
    #
    # @param [Array<Report::Test>] test_reports
    #
    # @return [Boolean]
    #
    # @api private
    #
    def self.success?(test_result)
      self::TEST_PASS_SUCCESS.equal?(test_result.passed)
    end

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
      subject.prepare
      Loader::Eval.call(root, subject)
      self
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

    # Return mutated root node
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def root
      subject.context.root(node)
    end

    # Evil mutation that should case mutations to fail tests
    class Evil < self

      SYMBOL            = 'evil'.freeze
      TEST_PASS_SUCCESS = false

    end # Evil

    # Neutral mutation that should not cause mutations to fail tests
    class Neutral < self

      SYMBOL            = 'neutral'.freeze
      TEST_PASS_SUCCESS = true

    end # Neutral

    # Noop mutation, special case of neutral
    class Noop < Neutral

      SYMBOL            = 'noop'.freeze
      TEST_PASS_SUCCESS = true

    end # Noop

  end # Mutation
end # Mutant
