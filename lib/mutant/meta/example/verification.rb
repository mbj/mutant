module Mutant
  module Meta
    class Example
      # Example verification
      class Verification
        include Adamantium::Flat, Concord.new(:example, :mutations)

        # Test if mutation was verified successfully
        #
        # @return [Boolean]
        def success?
          missing.empty? && unexpected.empty? && no_diffs.empty?
        end

        # Error report
        #
        # @return [String]
        def error_report
          fail 'no error report on successful validation' if success?

          YAML.dump(
            'file'            => example.file,
            'original_ast'    => example.node.inspect,
            'original_source' => example.source,
            'missing'         => format_mutations(missing),
            'unexpected'      => format_mutations(unexpected),
            'no_diff'         => no_diff_report
          )
        end

      private

        # Unexpected mutations
        #
        # @return [Array<Parser::AST::Node>]
        def unexpected
          mutations.map(&:node) - example.expected
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
        # @param [Array<Parser::AST::Node>] nodes
        #
        # @return [Array<Hash>]
        def format_mutations(nodes)
          nodes.map do |node|
            {
              'node'   => node.inspect,
              'source' => Unparser.unparse(node)
            }
          end
        end

        # No diff mutation report
        #
        # @return [Array, nil]
        def no_diff_report
          no_diffs.map do |mutation|
            {
              'node'   => mutation.node.inspect,
              'source' => mutation.source
            }
          end
        end

        # Missing mutations
        #
        # @return [Array<Parser::AST::Node>]
        def missing
          example.expected - mutations.map(&:node)
        end
        memoize :missing

      end # Verification
    end # Example
  end # Meta
end # Mutant
