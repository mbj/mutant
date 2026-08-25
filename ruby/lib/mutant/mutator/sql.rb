# frozen_string_literal: true

module Mutant
  class Mutator
    # Mutator for SQL embedded in Ruby heredoc strings
    #
    # Operates on the raw SQL text and emits mutated SQL strings.
    # All mutations are orthogonal replacements (circular) following
    # mutant's direction rules — see CONTRIBUTING.md §"Mutation Direction Rules".
    class Sql < self

      # Combined pattern matching SQL keywords to mutate.
      # Alternation is ordered so longer patterns match first,
      # preventing e.g. "IN" from matching inside "NOT IN".
      PATTERN = /
        (?:
          \bIS\s+NOT\s+NULL\b
        | \bIS\s+NULL\b
        | \bNOT\s+EXISTS\b
        | \bEXISTS\b
        | \bNOT\s+IN\b
        | \bIN\b
        | \bAND\b
        | \bOR\b
        | \bASC\b
        | \bDESC\b
        )
      /ix

      # Replacement for each matched keyword, keyed by whitespace-normalized
      # lowercased match text.
      REPLACEMENTS = {
        'is not null' => 'IS NULL',
        'is null'     => 'IS NOT NULL',
        'not exists'  => 'EXISTS',
        'exists'      => 'NOT EXISTS',
        'not in'      => 'IN',
        'in'          => 'NOT IN',
        'and'         => 'OR',
        'or'          => 'AND',
        'asc'         => 'DESC',
        'desc'        => 'ASC'
      }.freeze

      # Generate SQL mutations
      #
      # @param [String] sql
      #
      # @return [Set<String>]
      def self.mutate(sql)
        new(input: sql, parent: nil).output
      end

    private

      def dispatch
        input.scan(PATTERN) do
          match = ::Regexp.last_match
          replacement = REPLACEMENTS.fetch(normalize(match[0]))
          emit(splice(match.begin(0), match.end(0), replacement))
        end
      end

      def normalize(text)
        text.downcase.gsub(/\s+/, ' ')
      end

      def splice(start, stop, replacement)
        input[0...start] + replacement + input[stop..]
      end
    end # Sql
  end # Mutator
end # Mutant
