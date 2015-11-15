module Mutant
  class Matcher

    # Compiler for complex matchers
    class Compiler
      include Concord.new(:config), AST::Sexp, Procto.call(:result)

      # Generated matcher
      #
      # @return [Matcher]
      def result
        Filter.new(
          Chain.new(config.match_expressions.map(&:matcher)),
          Morpher::Evaluator::Predicate::Boolean::And.new(
            [
              ignored_subjects,
              filtered_subjects
            ]
          )
        )
      end

      # Subject expression prefix predicate
      class SubjectPrefix
        include Concord.new(:expression)

        # Test if subject expression is matched by prefix
        #
        # @return [Boolean]
        def call(subject)
          expression.prefix?(subject.expression)
        end

      end # SubjectPrefix

    private

      # Predicate returning false on expression ignored subject
      #
      # @return [#call]
      def ignored_subjects
        Morpher::Evaluator::Predicate::Boolean::Negation.new(
          Morpher::Evaluator::Predicate::Boolean::Or.new(
            config.ignore_expressions.map(&SubjectPrefix.method(:new))
          )
        )
      end

      # Predicate returning false on filtered subject
      #
      # @return [#call]
      def filtered_subjects
        Morpher::Evaluator::Predicate::Boolean::And.new(config.subject_filters)
      end

    end # Compiler
  end # Matcher
end # Mutant
