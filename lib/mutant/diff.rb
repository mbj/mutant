# encoding: utf-8

module Mutant
  # Class to create diffs from source code
  class Diff
    include Adamantium::Flat, Concord.new(:old, :new)

    # Return source diff
    #
    # @return [String]
    #   if there is a diff
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def diff
      case diffs.length
      when 0
        nil
      when 1
        ::Diff::LCS::Hunk.new(old, new, diffs.first, max_length, 0)
          .diff(:unified) << "\n"
      else
        $stderr.puts(
          'Mutation resulted in more than one diff, should not happen! ' \
          'PLS report a bug!'
        )
        nil
      end
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
    memoize :diffs

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
      when '+'
        Color::GREEN
      when '-'
        Color::RED
      else
        Color::NONE
      end.format(line)
    end

  end # Diff
end # Mutant
