module Mutant
  # Class to create diffs from source code
  class Diff
    include Adamantium::Flat, Concord.new(:old, :new)

    ADDITION = '+'.freeze
    DELETION = '-'.freeze
    NEWLINE  = "\n".freeze

    # Return source diff
    #
    # @return [String]
    #   if there is exactly one diff
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def diff
      return if diffs.empty?

      minimized_hunks.map do |hunk|
        hunk.diff(:unified) << NEWLINE
      end.join
    end
    memoize :diff

    # Return colorized source diff
    #
    # @return [String]
    #   if there is a diff
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def colorized_diff
      return unless diff
      diff.lines.map(&self.class.method(:colorize_line)).join
    end
    memoize :colorized_diff

    # Return new object
    #
    # @param [String] old
    # @param [String] new
    #
    # @return [Diff]
    #
    # @api private
    #
    def self.build(old, new)
      new(lines(old), lines(new))
    end

    # Break up source into lines
    #
    # @param [String] source
    #
    # @return [Array<String>]
    #
    # @api private
    #
    def self.lines(source)
      source.lines.map { |line| line.chomp }
    end
    private_class_method :lines

  private

    # Return diffs
    #
    # @return [Array<Array>]
    #
    # @api private
    #
    def diffs
      ::Diff::LCS.diff(old, new)
    end

    # Return hunks
    #
    # @return [Array<Diff::LCS::Hunk>]
    #
    # @api private
    #
    def hunks
      diffs.map do |diff|
        ::Diff::LCS::Hunk.new(old, new, diff, max_length, 0)
      end
    end

    # Return minimized hunks
    #
    # @return [Array<Diff::LCS::Hunk>]
    #
    # @api private
    #
    def minimized_hunks
      head, *tail = hunks()

      tail.each_with_object([head]) do |right, aggregate|
        left = aggregate.last
        if right.overlaps?(left)
          right.merge(left)
          aggregate.pop
        end
        aggregate << right
      end
    end

    # Return max length
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def max_length
      [old, new].map(&:length).max
    end

    # Return colorized diff line
    #
    # @param [String] line
    #
    # @return [String]
    #
    # @api private
    #
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
