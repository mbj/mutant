module Mutant
  module Meta
    class Example
      include Adamantium, Concord::Public.new(:file, :node, :mutations)

      # Verification instance for example
      #
      # @return [Verification]
      def verification
        Verification.new(self, generated)
      end

      # Normalized source
      #
      # @return [String]
      def source
        Unparser.unparse(node)
      end
      memoize :source

      # Generated mutations on example source
      #
      # @return [Enumerable<Mutant::Mutation>]
      def generated
        Mutator.each(node).map do |node|
          Mutation::Evil.new(self, node)
        end
      end
      memoize :generated

      # Example verification
      class Verification
        include Adamantium::Flat, Concord.new(:example, :mutations)

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        def success?
          unparser.success? && missing.empty? && unexpected.empty? && no_diffs.empty?
        end

        # Error report
        #
        # @return [String]
        def error_report
          unless unparser.success?
            return unparser.report
          end
          mutation_report
        end

      private

        # Unexpected mutations
        #
        # @return [Array<Parser::AST::Node>]
        def unexpected
          mutations.map(&:node) - example.mutations
        end
        memoize :unexpected

        # Mutations with no diff to original
        #
        # @return [Enumerable<Mutation>]
        def no_diffs
          mutations.select { |mutation| mutation.source.eql?(example.source) }
        end
        memoize :no_diffs

        # Mutation report
        #
        # @return [String]
        def mutation_report
          original_node = example.node
          [
            "#{example.file}, Original-AST:",
            original_node.inspect,
            'Original-Source:',
            example.source,
            *missing_report,
            *unexpected_report,
            *no_diff_report
          ].join("\n======\n")
        end

        # Missing mutation report
        #
        # @return [Array, nil]
        def missing_report
          [
            'Missing mutations:',
            missing.map(&method(:format_mutation)).join("\n-----\n")
          ] if missing.any?
        end

        # No diff mutation report
        #
        # @return [Array, nil]
        def no_diff_report
          [
            'No source diffs to original:',
            no_diffs.map do |mutation|
              "#{mutation.node.inspect}\n#{mutation.source}"
            end
          ] if no_diffs.any?
        end

        # Unexpected mutation report
        #
        # @return [Array, nil]
        def unexpected_report
          [
            'Unexpected mutations:',
            unexpected.map(&method(:format_mutation)).join("\n-----\n")
          ] if unexpected.any?
        end

        # Format mutation
        #
        # @return [String]
        def format_mutation(node)
          [
            node.inspect,
            Unparser.unparse(node)
          ].join("\n")
        end

        # Missing mutations
        #
        # @return [Array<Parser::AST::Node>]
        def missing
          example.mutations - mutations.map(&:node)
        end
        memoize :missing

        # Unparser verifier
        #
        # @return [Unparser::CLI::Source]
        def unparser
          Unparser::CLI::Source::Node.new(Unparser::Preprocessor.run(example.node))
        end
        memoize :unparser

      end # Verification
    end # Example
  end # Meta
end # Mutant
