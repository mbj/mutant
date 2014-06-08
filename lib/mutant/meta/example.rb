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

      # Return generated mutations
      #
      # @return [Emumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def generated
        Mutant::Mutator.each(node).to_a
      end
      memoize :generated

      # Example verification
      class Verification
        include Adamantium::Flat, Concord.new(:example, :generated)

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        #
        # @api private
        #
        def success?
          unparser.success? && missing.empty? && unexpected.empty?
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
          generated - example.mutations
        end
        memoize :unexpected

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
            Unparser.unparse(original_node),
            *missing_report,
            *unexpected_report
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

        # Return missing mutationso
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def missing
          example.mutations - generated
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
