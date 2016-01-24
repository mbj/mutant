module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat
    include Concord::Public.new(:subject, :node)

    CODE_DELIMITER = "\0".freeze
    CODE_RANGE     = (0..4).freeze

    # Identification string
    #
    # @return [String]
    def identification
      "#{self.class::SYMBOL}:#{subject.identification}:#{code}"
    end
    memoize :identification

    # Mutation code
    #
    # @return [String]
    def code
      sha1[CODE_RANGE]
    end
    memoize :code

    # Normalized mutation source
    #
    # @return [String]
    def source
      Unparser.unparse(node)
    end
    memoize :source

    # Normalized original source
    #
    # @return [String]
    def original_source
      subject.source
    end

    # Test if mutation is killed by test reports
    #
    # @param [Result::Test] test_result
    #
    # @return [Boolean]
    def self.success?(test_result)
      self::TEST_PASS_SUCCESS.equal?(test_result.passed)
    end

    # Insert mutated node
    #
    # @param kernel [Kernel]
    #
    # @return [self]
    def insert(kernel)
      subject.prepare
      Loader.call(
        binding: TOPLEVEL_BINDING,
        kernel:  kernel,
        node:    root,
        subject: subject
      )
      self
    end

  private

    # SHA1 sum of source and subject identification
    #
    # @return [String]
    def sha1
      Digest::SHA1.hexdigest(subject.identification + CODE_DELIMITER + source)
    end
    memoize :sha1

    # Mutated root node
    #
    # @return [Parser::AST::Node]
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
