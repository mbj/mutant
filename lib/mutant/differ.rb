module Mutant
  # Class to create diffs from source code
  class Differ
    include Adamantium::Flat

    # Return source diff
    #
    # @return [String]
    #
    # @api private
    #
    def diff
      output = ''
      @diffs.each do |piece|
        hunk = Diff::LCS::Hunk.new(@old, @new, piece, CONTEXT_LINES, length_difference)
        output << hunk.diff(FORMAT)
        output << "\n"
      end
      output
    end
    memoize :diff

    # Return colorized source diff
    #
    # @return [String]
    #
    # @api private
    #
    def colorized_diff
      diff.lines.map do |line|
        self.class.colorize_line(line)
      end.join
    end
    memoize :colorized_diff

  private

    FORMAT = :unified
    CONTEXT_LINES = 3

    # Initialize differ object
    #
    # @param [String] old
    # @param [String] new
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(old, new)
      @old, @new = lines(old), lines(new)
      @diffs = Diff::LCS.diff(@old, @new)
    end

    # Break up sorce into lines
    #
    # @param [String] source
    #
    # @return [Array<String>]
    #
    # @api private
    #
    def lines(source)
      self.class.lines(source)
    end

    # Return length difference
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def length_difference
      @new.size - @old.size
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

    # Return colorized diff line
    #
    # @param [String] line
    #
    # @return [String]
    #   returns colorized line
    #
    # @api private
    #
    def self.colorize_line(line)
      case line[0].chr
      when '+'
        Color::GREEN
      when '-'
        Color::RED
      when '@'
        line[1].chr == '@' ? Color::BLUE : Color::NONE
      else
        Color::NONE
      end.format(line)
    end

  end # Differ
end # Mutant
