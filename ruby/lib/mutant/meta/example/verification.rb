# frozen_string_literal: true

module Mutant
  module Meta
    # rubocop:disable Metrics/ClassLength
    class Example
      # Example verification
      class Verification
        include Adamantium, Anima.new(:example, :invalid, :valid)

        def self.from_mutations(example:, mutations:)
          valid, invalid = [], []

          mutations.each do |mutation|
            mutation.either(invalid.public_method(:<<), valid.public_method(:<<))
          end

          new(example:, invalid:, valid:)
        end

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        def success?
          [
            invalid_report,
            missing,
            no_diffs,
            original_verification_report,
            unexpected
          ].all?(&:empty?)
        end
        memoize :success?

        def error_report
          reports.join("\n")
        end

      private

        def reports
          reports = [example.location]
          reports.concat(original_report)
          reports.concat(original_verification_report)
          reports.concat(make_report('Missing mutations:', missing))
          reports.concat(make_report('Unexpected mutations:', unexpected))
          reports.concat(make_report('No-Diff mutations:', no_diffs))
          reports.concat(invalid_report)
        end

        def make_report(label, mutations)
          if mutations.any?
            [label, mutations.map(&method(:report_mutation))]
          else
            []
          end
        end

        def report_mutation(mutation)
          [
            mutation.node.inspect,
            mutation.source
          ]
        end

        def original_report
          [
            "Original: (operators: #{example.operators.class.operators_name})",
            example.node,
            example.original_source
          ]
        end

        def original_verification_report
          validation = Unparser::Validation.from_string(example.original_source)
          if validation.success?
            []
          else
            [
              prefix('[original]', validation.report)
            ]
          end
        end

        def prefix(prefix, string)
          string.each_line.map do |line|
            "#{prefix} #{line}"
          end.join
        end

        def invalid_report
          invalid.map do |validation|
            prefix('[invalid-mutation]', validation.report)
          end
        end
        memoize :invalid_report

        def unexpected
          valid.reject do |mutation|
            example.expected.any? { |expected| expected.node.eql?(mutation.node) }
          end
        end
        memoize :unexpected

        def missing
          example.expected.each_with_object([]) do |expected, aggregate|
            next if valid.any? { |mutation| expected.node.eql?(mutation.node) }
            aggregate << Mutation::Evil.new(
              node:    expected.node,
              source:  expected.original_source,
              subject: example
            )
          end
        end
        memoize :missing

        def no_diffs
          valid.select { |mutation| mutation.source.eql?(example.source) }
        end
        memoize :no_diffs

        def format_mutations(mutations)
          mutations.map do |mutation|
            {
              'node'   => mutation.node.inspect,
              'source' => mutation.source
            }
          end
        end

        def no_diff_report
          no_diffs.map do |mutation|
            {
              'node'   => mutation.node.inspect,
              'source' => mutation.source
            }
          end
        end

      end # Verification
    end # Example
  end # Meta
end # Mutant
