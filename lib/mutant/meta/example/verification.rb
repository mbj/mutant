# frozen_string_literal: true

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
          [missing, unexpected, no_diffs, invalid_syntax].all?(&:empty?)
        end
        memoize :success?

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
            'invalid_syntax'  => format_mutations(invalid_syntax),
            'no_diff'         => no_diff_report
          )
        end
        memoize :error_report

      private

        # Unexpected mutations
        #
        # @return [Array<Mutation>]
        def unexpected
          mutations.reject do |mutation|
            example.expected.include?(mutation.node)
          end
        end
        memoize :unexpected

        # Missing mutations
        #
        # @return [Array<Mutation>]
        def missing
          (example.expected - mutations.map(&:node)).map do |node|
            Mutation::Evil.new(self, node)
          end
        end
        memoize :missing

        # Mutations that generated invalid syntax
        #
        # @return [Enumerable<Mutation>]
        def invalid_syntax
          mutations.reject do |mutation|
            ::Parser::CurrentRuby.parse(mutation.source)
          rescue ::Parser::SyntaxError # rubocop:disable Lint/HandleExceptions
          end
        end
        memoize :invalid_syntax

        # Mutations with no diff to original
        #
        # @return [Enumerable<Mutation>]
        def no_diffs
          mutations.select { |mutation| mutation.source.eql?(example.source) }
        end
        memoize :no_diffs

        # Mutation report
        #
        # @param [Array<Mutation>] mutations
        #
        # @return [Array<Hash>]
        def format_mutations(mutations)
          mutations.map do |mutation|
            {
              'node'   => mutation.node.inspect,
              'source' => mutation.source
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

      end # Verification
    end # Example
  end # Meta
end # Mutant
