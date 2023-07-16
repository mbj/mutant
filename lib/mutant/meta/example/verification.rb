# frozen_string_literal: true

module Mutant
  module Meta
    class Example
      # Example verification
      class Verification
        include Adamantium, Anima.new(:example, :mutations)

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        def success?
          [
            original_verification,
            invalid,
            missing,
            no_diffs,
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
          reports.concat(original)
          reports.concat(original_verification)
          reports.concat(make_report('Missing mutations:', missing))
          reports.concat(make_report('Unexpected mutations:', unexpected))
          reports.concat(make_report('No-Diff mutations:', no_diffs))
          reports.concat(invalid)
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

        def original
          [
            "Original: (operators: #{example.operators.class.operators_name})",
            example.node,
            example.original_source
          ]
        end

        def original_verification
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

        def invalid
          mutations.each_with_object([]) do |mutation, aggregate|
            validation = Unparser::Validation.from_node(mutation.node)
            aggregate << prefix('[invalid-mutation]', validation.report) unless validation.success?
          end
        end
        memoize :invalid

        def unexpected
          mutations.reject do |mutation|
            example.expected.any? { |expected| expected.node.eql?(mutation.node) }
          end
        end
        memoize :unexpected

        def missing
          (example.expected.map(&:node) - mutations.map(&:node)).map do |node|
            Mutation::Evil.new(subject: example, node: node)
          end
        end
        memoize :missing

        def no_diffs
          mutations.select { |mutation| mutation.source.eql?(example.original_source_generated) }
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
