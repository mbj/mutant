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

      def initialize
        @start = Time.now
        @noop_fails = @subjects = @mutations = @kills = @time = 0
      end

      def runtime
        Time.now - @start
      end

      def subject
        @subjects +=1
        self
      end

      def alive
        @mutations - @kills
      end

      def noop_fail(killer)
        @noop_fails += 1
        @time += killer.runtime
        self
      end

      def killer(killer)
        @mutations +=1
        @kills +=1 unless killer.fail?
        @time += killer.runtime
        self
      end

    end
  end
end
