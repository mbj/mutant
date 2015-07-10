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
          ignored_subjects
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

      # Predicate returning false on ignored subject
      #
      # @return [#call]
      #
      # @api private
      def ignored_subjects
        rejectors = config.ignore_expressions.map(&SubjectPrefix.method(:new))

        if rejectors.any?
          Morpher::Evaluator::Predicate::Boolean::Negation.new(
            Morpher::Evaluator::Predicate::Boolean::Or.new(rejectors)
          )
        else
          Morpher::Evaluator::Predicate::Tautology.new
        end
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
