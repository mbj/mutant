module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Equalizer.new(:io)

      class Stats
        attr_reader :subject
        attr_reader :mutation
        attr_reader :kill
        attr_reader :time

        def initialize
          @start = Time.now
          @subject = @mutation = @kill = @time = 0
        end

        def runtime
          Time.now - @start
        end

        def subject
          @subject +=1
        end

        def alive
          @mutation - @kill
        end

        def killer(killer)
          @mutation +=1
          @kill +=1 unless killer.fail?
          @time += killer.runtime
        end
      end

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

      # Retun stats
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
        differ = Differ.new(killer.original_source,killer.mutation_source)
        diff = color? ? differ.colorized_diff : differ.diff
        # FIXME remove this branch before release
        if diff.empty?
          killer.send(:mutation).node.ascii_graph
          killer.send(:mutation).subject.node.ascii_graph
          raise "Unable to create a diff"
        end
        puts(diff)
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
