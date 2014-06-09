# encoding: UTF-8

module Mutant
  module Meta
    class Example
      include Adamantium, Concord::Public.new(:node, :mutations)

      # Return a verification instance
      #
      # @return [Verification]
      #
      # @api private
      #
      def verification
        Verification.new(self, generated)
      end

      # Return source
      #
      # @return [String]
      #
      # @api private
      #
      def source
        Unparser.unparse(node)
      end
      memoize :source

      # Return generated mutations
      #
      # @return [Emumerable<Mutant::Mutation>]
      #
      # @api private
      #
      def generated
        Mutant::Mutator.each(node).map do |node|
          Mutant::Mutation::Evil.new(self, node)
        end
      end
      memoize :generated

      # Example verification
      class Verification
        include Adamantium::Flat, Concord.new(:example, :mutations)

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        #
        # @api private
        #
        def success?
          unparser.success? && missing.empty? && unexpected.empty? && no_diffs.empty?
        end

        # Return error report
        #
        # @return [String]
        #
        # @api private
        #
        def error_report
          unless unparser.success?
            return unparser.report
          end
          mutation_report
        end

      private

        # Return unexpected mutationso
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def unexpected
          mutations.map(&:node) - example.mutations
        end
        memoize :unexpected

        # Return mutations with no diff to original
        #
        # @return [Enumerable<Mutation>]
        #
        # @api private
        #
        def no_diffs
          mutations.select { |mutation| mutation.source.eql?(example.source) }
        end
        memoize :no_diffs

        # Return mutation report
        #
        # @return [String]
        #
        # @api private
        #
        def mutation_report
          original_node = example.node
          [
            'Original-AST:',
            original_node.inspect,
            'Original-Source:',
            example.source,
            *missing_report,
            *unexpected_report,
            *no_diff_report,
          ].join("\n======\n")
        end

        # Return missing report
        #
        # @return [Array, nil]
        #
        # @api private
        #
        def missing_report
          [
            'Missing mutations:',
            missing.map(&method(:format_mutation)).join("\n-----\n")
          ] if missing.any?
        end

        # Return no diff report
        #
        # @return [Array, nil]
        #
        # @api private
        #
        def no_diff_report
          [
            'No source diffs to original:',
            no_diffs.map do |mutation|
              "#{mutation.node.inspect}\n#{mutation.source}"
            end
          ] if no_diffs.any?
        end

        # Return unexpected report
        #
        # @return [Array, nil]
        #
        # @api private
        #
        def unexpected_report
          [
            'Unexpected mutations:',
            unexpected.map(&method(:format_mutation)).join("\n-----\n")
          ] if unexpected.any?
        end

        # Format mutation
        #
        # @return [String]
        #
        # @api private
        #
        def format_mutation(node)
          [
            node.inspect,
            Unparser.unparse(node)
          ].join("\n")
        end

        # Return missing mutations
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def missing
          example.mutations - mutations.map(&:node)
        end
        memoize :missing

        # Return unparser verifier
        #
        # @return [Unparser::CLI::Source]
        #
        # @api private
        #
        def unparser
          Unparser::CLI::Source::Node.new(Unparser::Preprocessor.run(example.node))
        end
        memoize :unparser

      end # Verification
    end # Example
  end # Meta
end # Mutant
