module Mutant
  class Differ
    include Immutable

    def initialize(old, new)
      @new, @old = new.lines.map(&:chomp), old.lines.map(&:chomp)
      @diffs = Diff::LCS.diff(@old, @new)
    end

    def format
      :unified
    end

    def context_lines
      3
    end

    def length_difference
      @new.size - @old.size
    end

    def diff
      output = ''
      @diffs.each do |piece|
        hunk = Diff::LCS::Hunk.new(@old, @new, piece, context_lines, length_difference)
        output << hunk.diff(format)
        output << "\n"
      end
      output
    end
    memoize :diff

    def colorized_diff
      diff.lines.map do |line|
        self.class.colorize_line(line)
      end.join
    end
    memoize :colorized_diff

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
  end
end

