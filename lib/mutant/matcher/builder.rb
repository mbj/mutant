module Mutant
  class Matcher
    # Builder for complex matchers
    class Builder
      include NodeHelpers, Concord.new(:cache)

      # Initalize object
      #
      # @param [Cache] cache
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(cache)
        super
        @matchers          = []
        @subject_ignores   = []
        @subject_selectors = []
      end

      # Add a subject ignore
      #
      # @param [Expression] expression
      #
      # @return [self]
      #
      # @api private
      #
      def add_subject_ignore(expression)
        @subject_ignores << expression.matcher(cache)
        self
      end

      # Add a subject selector
      #
      # @param [#call] selector
      #
      # @return [self]
      #
      # @api private
      #
      def add_subject_selector(selector)
        @subject_selectors << selector
        self
      end

      # Add a match expression
      #
      # @param [Expression] expression
      #
      # @return [self]
      #
      # @api private
      #
      def add_match_expression(expression)
        @matchers << expression.matcher(cache)
        self
      end

      # Return generated matcher
      #
      # @return [Mutant::Matcher]
      #
      # @api private
      #
      def matcher
        if @matchers.empty?
          return Matcher::Null.new
        end

        matcher = Matcher::Chain.build(@matchers)

        if predicate
          Matcher::Filter.new(matcher, predicate)
        else
          matcher
        end
      end

    private

      # Return subject selector
      #
      # @return [#call]
      #   if selector is present
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def subject_selector
        Morpher::Evaluator::Predicate::Boolean::Or.new(@subject_selectors) if @subject_selectors.any?
      end

      # Return predicate
      #
      # @return [#call]
      #   if filter is needed
      #
      # @return [nil]
      #   othrwise
      #
      # @api private
      #
      def predicate
        if subject_selector && subject_rejector
          Morpher::Evaluator::Predicate::Boolean::And.new([
            subject_selector,
            Morpher::Evaluator::Predicate::Negation.new(subject_rejector)
          ])
        elsif subject_selector
          subject_selector
        elsif subject_rejector
          Morpher::Evaluator::Predicate::Negation.new(subject_rejector)
        else
          nil
        end
      end

      # Return subject rejector
      #
      # @return [#call]
      #   if there is a subject rejector
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def subject_rejector
        rejectors = @subject_ignores.flat_map(&:to_a).map do |subject|
          Morpher.compile(s(:eql, s(:attribute, :identification), s(:static, subject.identification)))
        end

        Morpher::Evaluator::Predicate::Boolean::Or.new(rejectors) if rejectors.any?
      end

    end # Builder
  end # Matcher
end # Mutant
