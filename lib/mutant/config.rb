module Mutant
  # The configuration of a mutator run
  class Config
    include Adamantium::Flat, Anima.new(
      :debug,
      :strategy,
      :matcher,
      :reporter,
      :fail_fast,
      :zombie,
      :expected_coverage
    )

    # Enumerate subjects
    #
    # @api private
    #
    # @return [self]
    #   if block given
    #
    # @return [Enumerator<Subject>]
    #   otherwise
    #
    # @api private
    #
    def subjects(&block)
      return to_enum(__method__) unless block_given?
      matcher.each(&block)
      self
    end

    # Return tests for mutation
    #
    # TODO: This logic is now centralized but still fucked.
    #
    # @param [Mutation] mutation
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    #
    def tests(subject)
      subject.match_expressions.each do |match_expression|
        tests = strategy.all_tests.select do |test|
          match_expression.prefix?(test.expression)
        end
        return tests if tests.any?
      end

      EMPTY_ARRAY
    end

  end # Config
end # Mutant
