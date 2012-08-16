module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      # Reporter subject
      #
      # @param [Subject] subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject(subject)
        @io.puts("Subject: #{subject.identification}")
      end

      # Report mutations 
      #
      # @param [Mutation] mutations
      #
      # @return [self]
      #
      # @api private
      #
      def mutation(mutation)
        @io.puts("Mutation: #{mutation.identification}")
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
        if killer.fail?
          @io.puts(colorize(Color::RED, "!!! Uncovered Mutation !!!"))
          differ = Differ.new(killer.original_source,killer.mutation_source)
          diff = color? ? differ.colorized_diff : differ.diff
          @io.puts(diff)
          @io.puts
        end

        self
      end

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
      def colorize(color, message)
        color = Color::NONE unless color?
        color.format(message)
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
