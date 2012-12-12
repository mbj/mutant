module Mutant
  class Reporter

    # Stats gathered while reporter is running
    class Stats

      # Return subject count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :subjects

      # Return mutation count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :mutations

      # Return skip count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :noop_fails

      # Return kill count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :kills

      # Return mutation runtime
      #
      # @return [Float]
      #
      # @api private
      #
      attr_reader :time

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @start = Time.now
        @noop_fails = @subjects = @mutations = @kills = @time = 0
      end

      # Return runtime in seconds
      #
      # @return [Float]
      #
      # @api private
      #
      def runtime
        Time.now - @start
      end

      # Count subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject
        @subjects +=1
        self
      end

      # Return number of mutants alive
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def alive
        @mutations - @kills
      end

      # Count noop mutation fail
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def noop_fail(killer)
        @noop_fails += 1
        @time += killer.runtime
        self
      end

      # Count killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def killer(killer)
        @mutations +=1
        @kills +=1 unless killer.fail?
        @time += killer.runtime
        self
      end

    end
  end
end
