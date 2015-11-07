module Mutant
  class Matcher

    # Compiler for complex matchers
    class Compiler
      include Concord.new(:config, :expression_parser), AST::Sexp, Procto.call(:result)

      # Generated matcher
      #
      # @return [Matcher]
      #
      # @api private
      #
      # rubocop:disable MethodLength
      def result
        Filter.new(
          Chain.new(
            config
              .match_expressions
              .map(&method(:parse_expression))
              .map(&:matcher)
          ),
          Morpher::Evaluator::Predicate::Boolean::And.new(
            [ignored_subjects, filtered_subjects]
          )
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

      # Predicate returning false on expression ignored subject
      #
      # @return [#call]
      #
      # @api private
      def ignored_subjects
        Morpher::Evaluator::Predicate::Boolean::Negation.new(
          Morpher::Evaluator::Predicate::Boolean::Or.new(
            config
              .ignore_expressions
              .map(&method(:parse_expression))
              .map(&SubjectPrefix.method(:new))
          )
        )
      end

      # Predicate returning false on filtered subject
      #
      # @return [#call]
      #
      # @api private
      def filtered_subjects
        Morpher::Evaluator::Predicate::Boolean::And.new(config.subject_filters)
      end

      # Parse expression
      #
      # @param [String] syntax
      #
      # @return [Expression]
      #
      # @api private
      def parse_expression(syntax)
        expression_parser.call(syntax)
      end

    end # Compiler
  end # Matcher
end # Mutant
