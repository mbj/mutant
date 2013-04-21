module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:io)

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
      # @param [Subject] 
      #
      # @return [undefined]
      #
      # @api private
      #
      def subject_results(runner)
        mutations = runner.mutations
        puts if mutations.any?
        time      = mutations.map(&:runtime).inject(0, :+)
        mutations = mutations.length
        fails     = runner.failed_mutations
        fails     = fails.length
        kills     = mutations - fails
        coverage  = kills.to_f / mutations * 100
        puts('(%02d/%02d) %3d%% - %0.02fs' % [kills, mutations, coverage, time])
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
        message = []
        message << 'Mutant configuration:'
        message << "Matcher:   #{config.matcher.inspect }"
        message << "Filter:    #{config.filter.inspect  }"
        message << "Strategy:  #{config.strategy.inspect}"
        puts message.join("\n")
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
        message   = []
        subjects  = runner.subjects
        mutations = subjects.map(&:mutations).flatten
        killtime  = mutations.map(&:runtime).inject(0, :+)
        kills     = mutations.select(&:success?)

        subjects  = subjects.length
        mutations = mutations.length
        kills     = kills.length
        coverage  = kills.to_f / mutations * 100
        runtime   = runner.runtime

        overhead  = (runtime - killtime) / runtime * 100

        puts "Subjects:  #{subjects}"
        puts "Mutations: #{mutations}"
        puts "Kills:     #{kills}"
        puts 'Runtime:   %0.2fs' % runtime
        puts 'Killtime:  %0.2fs' % killtime
        puts 'Overhead:  %0.2f%%' % overhead
        puts 'Coverage:  %0.2f%%' % coverage
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
