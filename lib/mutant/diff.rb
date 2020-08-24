# frozen_string_literal: true

module Mutant
  # Class to create diffs from source code
  class Diff
    include Adamantium::Flat, Concord.new(:old, :new)

    ADDITION = '+'
    DELETION = '-'
    NEWLINE  = "\n"

    # Unified source diff between old and new
    #
    # @return [String]
    #   if there is exactly one diff
    #
    # @return [nil]
    #   otherwise
    def diff
      return if diffs.empty?

      minimized_hunk.diff(:unified) + NEWLINE
    end
    memoize :diff

    # Colorized unified source diff between old and new
    #
    # @return [String]
    #   if there is a diff
    #
    # @return [nil]
    #   otherwise
    def colorized_diff
      return unless diff
      diff.lines.map(&self.class.method(:colorize_line)).join
    end
    memoize :colorized_diff

    # Build new object from source strings
    #
    # @param [String] old
    # @param [String] new
    #
    # @return [Diff]
    def self.build(old, new)
      new(lines(old), lines(new))
    end

    # Break up source into lines
    #
    # @param [String] source
    #
    # @return [Array<String>]
    def self.lines(source)
      source.lines.map(&:chomp)
    end
    private_class_method :lines

  private

    def diffs
      ::Diff::LCS.diff(old, new)
    end

    def hunks
      diffs.map do |diff|
        ::Diff::LCS::Hunk.new(old.map(&:dup), new, diff, max_length, 0)
      end
    end

    def minimized_hunk
      head, *tail = hunks

      tail.reduce(head) do |left, right|
        right.merge(left)
        right
      end
    end

    def max_length
      [old, new].map(&:length).max
    end

    def self.colorize_line(line)
      case line[0]
      when ADDITION
        Color::GREEN
      when DELETION
        Color::RED
      else
        Color::NONE
      end.format(line)
    end
    private_class_method :colorize_line

  end # Diff
end # Mutant
