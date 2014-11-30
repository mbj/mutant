module Mutant
  # Represent a mutated node with its subject
  class Mutation
    include AbstractType, Adamantium::Flat
    include Concord::Public.new(:subject, :node)

    CODE_DELIMITER = "\0".freeze
    CODE_RANGE     = (0..4).freeze

    # Kill mutation via isolation
    #
    # @param [Isolation] isolation
    #
    # @return [Result::Mutation]
    #
    # @api private
    #
    def kill(isolation)
      result = Result::Mutation.new(
        index:        nil,
        mutation:     self,
        test_results: []
      )

      subject.tests.reduce(result) do |current, test|
        return current unless current.continue?
        test_result = test.kill(isolation, self)
        current.update(
          test_results: current.test_results.dup << test_result
        )
      end
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
    abstract_singleton_method :success?

    # Test if execution can be continued
    #
    # @return [Boolean]
    #
    # @api private
    #
    abstract_singleton_method :continue?

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

      SYMBOL = 'evil'.freeze

      # Test if mutation is killed by test reports
      #
      # @param [Array<Report::Test>] test_reports
      #
      # @return [Boolean]
      #
      # @api private
      #
      def self.success?(test_results)
        !test_results.all?(&:passed)
      end

      # Test if mutation execution can be continued
      #
      # @return [Boolean]
      #
      # @api private
      #
      def self.continue?(test_results)
        !success?(test_results)
      end

    end # Evil

    # Neutral mutation that should not cause mutations to fail tests
    class Neutral < self

      SYMBOL = 'neutral'.freeze

      # Test if mutation is killed by test reports
      #
      # @param [Array<Report::Test>] test_reports
      #
      # @return [Boolean]
      #
      # @api private
      #
      def self.success?(test_results)
        test_results.any? && test_results.all?(&:passed)
      end

      # Test if mutation execution can be continued
      #
      # @return [Boolean] _test_results
      #
      # @api private
      #
      def self.continue?(_test_results)
        true
      end

    end # Neutral

    # Noop mutation, special case of neutral
    class Noop < Neutral

      SYMBOL = 'noop'.freeze

    end # Noop

  end # Mutation
end # Mutant
