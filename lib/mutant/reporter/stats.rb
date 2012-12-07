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
      attr_reader :subject

      # Return mutation count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :mutation

      # Return kill count
      #
      # @return [Fixnum]
      #
      # @api private
      #
      attr_reader :kill

      # Return mutation runtime
      #
      # @return [Float]
      #
      # @api private
      #
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

  end
end
