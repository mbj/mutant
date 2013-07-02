module Mutant
  # Class to create diffs from source code
  class Differ
    include Adamantium::Flat, Concord.new(:old, :new)

    # Return source diff
    #
    # @return [String]
    #
    # @api private
    #
    def diff
      output = ''
      case diffs.length
      when 0
        nil
      when 1
        output = Diff::LCS::Hunk.new(old, new, diffs.first, max_length, 0).diff(:unified)
        output << "\n"
      else
        raise 'Mutation resulted in more than one diff, should not happen!'
      end
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

    # Return new object
    #
    # @param [String] old
    # @param [String] new
    #
    # @return [Differ]
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
      Diff::LCS.diff(old, new)
    end
    memoize :diffs

    # Return max length
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def max_length
      old.length > new.length ? old.length : new.length
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
