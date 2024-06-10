# frozen_string_literal: true

module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium
    include Anima.new(:subject, :node)

    CODE_DELIMITER = "\0"
    CODE_RANGE     = (..4)

    # Mutation identification code
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

    # Identification string
    #
    # @return [String]
    def identification
      "#{self.class::SYMBOL}:#{subject.identification}:#{code}"
    end
    memoize :identification

    # The monkeypatch to insert the mutation
    #
    # @return [String]
    def monkeypatch
      Unparser.unparse(subject.context.root(node))
    end
    memoize :monkeypatch

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
    # @return [Loader::Result]
    def insert(kernel)
      subject.prepare
      Loader.call(
        binding: TOPLEVEL_BINDING,
        kernel:,
        source:  monkeypatch,
        subject:
      ).fmap do
        subject.post_insert
        nil
      end
    end

    # Rendered mutation diff
    #
    # @return [String, nil]
    #   the diff, if present
    def diff
      Unparser::Diff.build(original_source, source)
    end
    memoize :diff

  private

    def sha1
      Digest::SHA1.hexdigest(subject.identification + CODE_DELIMITER + source)
    end

    # Evil mutation that should case mutations to fail tests
    class Evil < self
      SYMBOL            = 'evil'
      TEST_PASS_SUCCESS = false

    end # Evil

    # Neutral mutation that should not cause mutations to fail tests
    class Neutral < self

      SYMBOL            = 'neutral'
      TEST_PASS_SUCCESS = true

    end # Neutral

    # Noop mutation, special case of neutral
    class Noop < Neutral

      SYMBOL            = 'noop'
      TEST_PASS_SUCCESS = true

    end # Noop

  end # Mutation
end # Mutant
