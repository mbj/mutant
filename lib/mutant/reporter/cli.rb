module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Equalizer.new(:io)

      # Reporter subject
      #
      # @param [Subject] subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject(subject)
        stats.subject
        puts("Subject: #{subject.identification}")
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
        colorized_diff(mutation.original_source, mutation.source)
        self
      end

      # Report config
      #
      # @param [Mutant::Config] config
      #
      # @return [self]
      #
      # @api private
      #
      def config(config)
        puts 'Mutant configuration:'
        puts "Matcher:   #{config.matcher.inspect}"
        puts "Filter:    #{config.filter.inspect}"
        puts "Strategy:  #{config.strategy.inspect}"
      end

      # Reporter killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def killer(killer)
        stats.killer(killer)

        color, word =
          if killer.fail?
            [Color::RED,   'Alive']
          else
            [Color::GREEN, 'Killed']
          end

        puts(colorize(color, "#{word}: #{killer.identification} (%02.2fs)" % killer.runtime))

        self
      end

      # Report errors
      #
      # @param [Enumerable<Killer>]
      #
      # @api private
      #
      # @return [self]
      #
      def errors(errors)
        errors.each do |error|
          failure(error)
        end

        puts
        puts "subjects:  #{stats.subject}"
        puts "mutations: #{stats.mutation}"
        puts "kills:     #{stats.kill}"
        puts "alive:     #{stats.alive}"
        puts "mtime:     %02.2fs" % stats.time
        puts "rtime:     %02.2fs" % stats.runtime
      end

      # Return IO stream
      #
      # @return [IO]
      #
      # @api private
      # 
      attr_reader :io

      # Return stats
      #
      # @return [Stats]
      #
      # @api private
      #
      attr_reader :stats

    private 

      # Initialize reporter
      #
      # @param [IO] io
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(io)
        @io = io
        @stats = Stats.new
      end

      # Report failure on killer
      # 
      # @param [Killer] killer
      #
      # @return [undefined]
      #
      # @api private
      #
      def failure(killer)
        puts(colorize(Color::RED, "!!! Mutant alive: #{killer.identification} !!!"))
        colorized_diff(killer.original_source, killer.mutation_source)
        puts("Took: (%02.2fs)" % killer.runtime)
      end

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
      # @param [String] original
      # @param [String] current
      #
      # @return [self]
      #
      # @api private
      #
      def colorized_diff(original, current)
        differ = Differ.new(original, current)
        diff = color? ? differ.colorized_diff : differ.diff
        # FIXME remove this branch before release
        if diff.empty?
          raise "Unable to create a diff, so ast mutation or to_source has an error!"
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
