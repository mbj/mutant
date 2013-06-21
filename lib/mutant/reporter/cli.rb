module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord::Public.new(:io)

      NL = "\n".freeze

      ACTIONS = {
        Config          => :config,
        Subject         => :subject,
        Killer          => :killer,
        Runner::Subject => :subject_results,
        Runner::Config  => :config_results
      }.freeze

      # Perform lookup
      #
      # @param [Object] object
      #
      # @return [Symbol]
      #   if found
      #
      # @raise [RuntimeError]
      #   otherwise
      #
      # @api private
      #
      def self.lookup(object)
        current = klass = object.class
        begin
          symbol = ACTIONS[current]
          return symbol if symbol
          current = current.superclass
        end while current < ::Object
        raise "No reporter for #{klass}"
      end

      # Report object
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def report(object)
        method = self.class.lookup(object)
        send(method, object)
        self
      end

    private

      # Report subject
      #
      # @param [Subject] subject
      #
      # @return [undefined]
      #
      # @api private
      #
      def subject(subject)
        puts
        puts(subject.identification)
      end
      # Report subject results
      #
      # @param [Subject] runner
      #
      # @return [undefined]
      #
      # @api private
      #
      def subject_results(runner)
        Printer::Subject.run(io, runner)
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

      # Report configuration
      #
      # @param [Mutant::Config] config
      #
      # @return [self]
      #
      # @api private
      #
      def config(config)
        puts 'Mutant configuration:'
        puts "Matcher:   #{config.matcher.inspect }"
        puts "Filter:    #{config.filter.inspect  }"
        puts "Strategy:  #{config.strategy.inspect}"
      end

      # Report configuration results
      #
      # TODO: Break this stuff into smaller methods or factor out in a subclass
      #
      # @param [Reporter::Config] runner
      #
      # @return [self]
      #
      # @api private
      #
      def config_results(runner)
        Printer::Config.run(io, runner)
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
        if killer.success?
          char('.', Color::GREEN)
          return
        end
        char('F', Color::RED)
        self
      end

      # Write colorized char
      #
      # @param [String] char
      # @param [Color]
      #
      # @return [undefined]
      #
      # @api private
      #
      def char(char, color)
        io = self.io
        io.write(colorize(color, char))
        io.flush
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
      def puts(string=NL)
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

    end # CLI
  end # Reporter
end # Mutant
