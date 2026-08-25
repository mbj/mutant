# frozen_string_literal: true

module Mutant
  class Mutator
    # Mutator for SQL embedded in Ruby heredoc strings
    #
    # Operates on the raw SQL text and emits mutated SQL strings.
    # All mutations are orthogonal replacements following mutant's
    # direction rules — see CONTRIBUTING.md §"Mutation Direction Rules".
    module Sql
      # Ordered longest-first so multi-word keywords match before their
      # sub-keywords (e.g. "IS NOT NULL" before "IS NULL", "NOT IN" before "IN").
      REPLACEMENTS = [
        ['IS NOT NULL', 'IS NULL'],
        ['IS NULL',     'IS NOT NULL'],
        ['NOT EXISTS',  'EXISTS'],
        ['EXISTS',      'NOT EXISTS'],
        ['NOT IN',      'IN'],
        ['IN',          'NOT IN'],
        ['AND',         'OR'],
        ['OR',          'AND'],
        ['ASC',         'DESC'],
        ['DESC',        'ASC']
      ].freeze

      MAP = REPLACEMENTS.to_h.freeze

      # Combined pattern matching SQL keywords to mutate.
      PATTERN = ::Regexp.new(
        REPLACEMENTS
          .map(&:first)
          .map { |keyword| "\\b#{keyword.gsub(/\s+/, '\\s+')}\\b" }
          .join('|'),
        ::Regexp::IGNORECASE
      ).freeze

      # Generate SQL mutations
      #
      # @param [String] sql
      #
      # @return [Set<String>]
      def self.mutate(sql)
        mutations = Set.new

        sql.scan(PATTERN) do
          match = ::Regexp.last_match
          replacement = MAP.fetch(match[0].upcase)
          mutations << splice(sql, match, replacement)
        end

        mutations
      end

      def self.splice(input, match, replacement)
        input[0...match.begin(0)] + replacement + input[match.end(0)..]
      end
      private_class_method :splice
    end # Sql
  end # Mutator
end # Mutant
