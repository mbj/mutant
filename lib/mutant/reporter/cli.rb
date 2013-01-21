module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self

      # Initialize reporter
      #
      # @param [Config] config
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(config)
        super
        @io = $stdout
      end

      # Reporte subject
      #
      # @param [Subject] subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject(subject)
        super
        puts("Subject: #{subject.identification}")
      end

      # Return error stream
      #
      # @return [IO]
      #
      # @api private
      #
      def error_stream
        debug? ? io : StringIO.new
      end

      # Return output stream
      #
      # @return [IO]
      #
      # @api private
      #
      def output_stream
        debug? ? io : StringIO.new
      end

      # Report mutation
      #
      # @param [Mutation] mutation
      #
      # @return [self]
      #
      # @api private
      #
      def mutation(mutation)
        super

        if debug?
          colorized_diff(mutation)
        end

        self
      end

      # Report start
      #
      # @param [Mutant::Config] config
      #
      # @return [self]
      #
      # @api private
      #
      def start(config)
        message = []
        message << 'Mutant configuration:'
        message << "Matcher:   #{config.matcher.inspect}"
        message << "Filter:    #{config.filter.inspect}"
        message << "Strategy:  #{config.strategy.inspect}"
        puts message.join("\n")
        super
      end

      # Report stop
      #
      # @return [self]
      #
      # @api private
      #
      def stop
        super
      end

      # Report killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def report_killer(killer)
        super

        status = killer.killed? ? 'Killed' : 'Alive'
        color  = killer.success? ? Color::GREEN : Color::RED

        puts(colorize(color, "%s: %s (%02.2fs)" % [status, killer.identification, killer.runtime]))

        unless killer.success?
          colorized_diff(killer.mutation)
        end

        self
      end

    private 

      # Return IO stream
      #
      # @return [IO]
      #
      # @api private
      # 
      attr_reader :io

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
          raise 'Unable to create a diff, so ast mutation or to_source has an error!'
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
