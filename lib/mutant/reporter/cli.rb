module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:io)

    private

      # Report subject
      #
      # @param [Subject] _subject
      #
      # @return [undefined]
      #
      # @api private
      #
      def subject(_subject)
      end

      # Report mutation
      #
      # @param [Mutation] _mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutation(_mutation)
      end

      # Report start
      #
      # @param [Mutant::Config] config
      #
      # @return [self]
      #
      # @api private
      #
      def config(config)
        message = []
        message << 'Mutant configuration:'
        message << "Matcher:   #{config.matcher.inspect }"
        message << "Filter:    #{config.filter.inspect  }"
        message << "Strategy:  #{config.strategy.inspect}"
        puts message.join("\n")
      end

      # Report killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def killer(killer)
        status = killer.killed? ? 'Killed' : 'Alive'
        color  = killer.success? ? Color::GREEN : Color::RED

        puts(colorize(color, "%s: %s (%02.2fs)" % [status, killer.identification, killer.runtime]))

        unless killer.success?
          colorized_diff(killer.mutation)
        end

        self
      end

    private

      # Test for colored output
      #
      # @return [true]
      #   returns true if output is colored
      #
      # @return [false]
      #   returns false otherwise
      #
      # @api private
      #
      def color?
        tty?
      end

      # Colorize message
      #
      # @param [Color] color
      # @param [String] message
      #
      # @api private
      #
      # @return [String]
      #   returns colorized string if color is enabled
      #   returns unmodified message otherwise
      #
      def colorize(color, message)
        color = Color::NONE unless color?
        color.format(message)
      end

      # Write string to io
      #
      # @param [String] string
      #
      # @return [undefined]
      #
      # @api private
      #
      def puts(string="\n")
        io.puts(string)
      end

      # Write colorized diff
      #
      # @param [Mutation] mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def colorized_diff(mutation)
        if mutation.kind_of?(Mutation::Neutral)
          puts mutation.original_source
          return
        end

        original, current = mutation.original_source, mutation.source
        differ = Differ.new(original, current)
        diff = color? ? differ.colorized_diff : differ.diff

        if diff.empty?
          raise 'Unable to create a diff, so ast mutant or to_source does something strange!!'
        end

        puts(diff)
        self
      end

      # Test for output to tty
      #
      # @return [true]
      #   returns true if output is a tty
      #
      # @return [false]
      #   returns false otherwise
      #
      # @api private
      #
      def tty?
        @io.respond_to?(:tty?) && @io.tty?
      end
      memoize :tty?

    end
  end
end
