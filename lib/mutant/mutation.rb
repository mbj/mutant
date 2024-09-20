# frozen_string_literal: true

module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium
    include Anima.new(:subject, :node, :source)

    CODE_DELIMITER = "\0"
    CODE_RANGE     = (..4)

    class GenerationError
      include Anima.new(:subject, :node, :unparser_violation)

      MESSAGE = <<~'MESSAGE'
        === Mutation-Generation-Error ===
        This is a mutant internal issue detected by a mutant internal cross check.
        Please report an issue with the details below.

        Subject: %<subject_identification>s.

        Mutation-Source-Diff:
        %<mutation_source_diff>s

        Mutation-Node-Diff:
        %<mutation_node_diff>s

        Unparser-Violation:
        %<unparser_violation>s
      MESSAGE

      def report
        MESSAGE % {
          mutation_source_diff:,
          mutation_node_diff:,
          subject_identification: subject.identification,
          unparser_violation: unparser_violation.report
        }
      end

    private

      def mutation_source_diff
        mutation = Mutation::Evil.new(
          subject:,
          node:,
          source: unparser_violation.original_source.from_right
        )

        mutation.diff.colorized_diff
      end

      def mutation_node_diff
        Unparser::Diff.new(
          subject.node.to_s.lines.map(&:chomp),
          node.to_s.lines.map(&:chomp)
        ).colorized_diff
      end
    end # GenerationError

    def self.from_node(subject:, node:)
      ast = Unparser::AST.from_node(node:)

      Unparser
        .unparse_validate_ast_either(ast:)
        .lmap { |unparser_violation| GenerationError.new(subject:, node:, unparser_violation:) }
        .fmap { |source| new(node:, source:, subject:) }
    end

    # Mutation identification code
    #
    # @return [String]
    def code
      sha1[CODE_RANGE]
    end
    memoize :code

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
