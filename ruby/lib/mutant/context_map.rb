# frozen_string_literal: true

module Mutant
  # Per test coverage, read from the artifact a coverage tool wrote.
  #
  # Mutant does not depend on the tool that produces the recording. It reads
  # the `contexts` sections of simplecov's `coverage.json`, which appear once
  # `track_tests` is enabled: an interned list of test ids, and per source file
  # a bitmap of the lines each of those tests executed.
  #
  # The recording answers the question the expression selector can only guess
  # at, which tests actually executed the lines a subject is made of.
  class ContextMap
    include Adamantium, Anima.new(:root, :tables)

    # Basename simplecov writes its report under
    ARTIFACT_BASENAME = 'coverage.json'

    # Report schema versions this reader understands
    SUPPORTED_SCHEMA = /\A1\./

    # Absolute `path:line` form of a location
    #
    # Test ids are recorded relative to the project root, while the
    # integrations report locations the way their framework spells them. Both
    # sides pass through here so that they compare as strings.
    #
    # @param [String] location
    # @param [String] root
    #
    # @return [String]
    def self.normalize(location, root)
      path, separator, line = location.rpartition(':')

      return location if separator.empty?

      "#{File.expand_path(path, root)}:#{line}"
    end

    # Absolute `path:line` form of a location, against this recording's root
    #
    # @param [String] location
    #
    # @return [String]
    def normalize(location) = self.class.normalize(location, root)

    # How many of `lines` in `path` each test executed, for the tests that
    # executed any of them
    #
    # The count is what ranks the tests: one that ran the whole method body is
    # likelier to reach a mutated expression than one that grazed a guard.
    #
    # @param [Pathname] path
    # @param [Range<Integer>] lines
    #
    # @return [Hash{String => Integer}]
    def reach(path:, lines:)
      table = tables.fetch(File.expand_path(path), nil)

      return EMPTY_HASH unless table

      # Bit N is line N+1, so the subject's lines are the bits from
      # `lines.begin - 1` up to and including `lines.end - 1`.
      mask = (1 << lines.end) - (1 << (lines.begin - 1))

      table.each_with_object({}) do |(context, bitmap), reached|
        covered = self.class.popcount(bitmap & mask)

        reached[context] = covered unless covered.zero?
      end
    end

    # Lines a test executed across the whole project
    #
    # The share of that footprint falling inside a subject is how focused the
    # test is on it. A unit test spends most of its lines there, while a
    # feature spec touching thousands of lines spends almost none.
    #
    # @param [String] context
    #
    # @return [Integer]
    def footprint(context) = footprints.fetch(context, 0)

    # Number of set bits
    #
    # Ruby has no population count on Integer, and a binary string is both the
    # idiom and fast enough at the sizes a line bitmap reaches.
    #
    # @param [Integer] value
    #
    # @return [Integer]
    def self.popcount(value) = value.to_s(2).count('1')

    # Every test id the recording knows about
    #
    # @return [Set<String>]
    def context_ids = tables.each_value.flat_map(&:keys).to_set
    memoize :context_ids

  private

    def footprints
      tables.each_value.with_object(Hash.new(0)) do |table, totals|
        table.each { |context, bitmap| totals[context] += self.class.popcount(bitmap) }
      end
    end
    memoize :footprints
  end # ContextMap
end # Mutant
