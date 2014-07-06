module Mutant
  class Matcher

    # Compiler for complex matchers
    class Compiler
      include Concord.new(:env, :config), AST::Sexp, Procto.call(:result)

      # Return generated matcher
      #
      # @return [Mutant::Matcher]
      #
      # @api private
      #
      def result
        matchers = config.match_expressions.map(&method(:matcher))

        if matchers.empty?
          return Matcher::Null.new
        end

        matcher = Matcher::Chain.build(matchers)

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
        selectors = config.subject_selects.map do |attribute, value|
          Morpher.compile(s(:eql, s(:attribute, attribute), s(:static, value)))
        end

        Morpher::Evaluator::Predicate::Boolean::Or.new(selectors) if selectors.any?
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
        rejectors = config.subject_ignores.map(&method(:matcher)).flat_map(&:to_a).map do |subject|
          Morpher.compile(s(:eql, s(:attribute, :identification), s(:static, subject.identification)))
        end

        Morpher::Evaluator::Predicate::Boolean::Or.new(rejectors) if rejectors.any?
      end

      # Return a matcher from expression
      #
      # @param [Mutant::Expression] expression
      #
      # @return [Matcher]
      #
      # @api private
      #
      def matcher(expression)
        expression.matcher(env)
      end

    end # Compiler
  end # Matcher
end # Mutant
