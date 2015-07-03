module Mutant
  class Matcher

    # Compiler for complex matchers
    class Compiler
      include Concord.new(:env, :config), AST::Sexp, Procto.call(:result)

      # Generated matcher
      #
      # @return [Matcher]
      #
      # @api private
      def result
        Filter.new(
          Chain.build(config.match_expressions.map(&method(:matcher))),
          predicate
        )
      end

      # Subject expression prefix predicate
      class SubjectPrefix
        include Concord.new(:expression)

        # Test if subject expression is matched by prefix
        #
        # @return [Boolean]
        #
        # @api private
        def call(subject)
          expression.prefix?(subject.expression)
        end

      end # SubjectPrefix

    private

      # Predicate constraining matches
      #
      # @return [#call]
      #
      # rubocop:disable MethodLength
      #
      # @api private
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
          Morpher::Evaluator::Predicate::Tautology.new
        end
      end

      # the subject selector predicate
      #
      # @return [#call]
      #   if selector is present
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      def subject_selector
        selectors = config.subject_selects.map do |attribute, value|
          Morpher.compile(s(:eql, s(:attribute, attribute), s(:static, value)))
        end

        Morpher::Evaluator::Predicate::Boolean::Or.new(selectors) if selectors.any?
      end

      # Subject rejector predicate
      #
      # @return [#call]
      #   if there is a subject rejector
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      def subject_rejector
        rejectors = config.subject_ignores.map(&SubjectPrefix.method(:new))

        Morpher::Evaluator::Predicate::Boolean::Or.new(rejectors) if rejectors.any?
      end

      # Matcher for expression on env
      #
      # @param [Mutant::Expression] expression
      #
      # @return [Matcher]
      #
      # @api private
      def matcher(expression)
        expression.matcher(env)
      end

    end # Compiler
  end # Matcher
end # Mutant
