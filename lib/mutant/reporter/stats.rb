module Mutant
  class Reporter

    # Stats gathered while reporter is running
    class Stats

      # A counter with fail counts
      class Counter
        include Equalizer.new(:count, :fails)

        # Return count
        #
        # @return [Fixnum]
        #
        # @api private
        #
        attr_reader :count

        # Return fail count
        #
        # @return [Fixnum]
        #
        # @api private
        #
        attr_reader :fails

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize
          @count = @fails = 0
        end

        # Count killer
        #
        # @param [Killer] killer
        #
        # @return [self]
        #
        # @api private
        #
        def handle(killer)
          @count += 1
          unless killer.success?
            @fails += 1
          end
          self
        end
      end

      include Equalizer.new(:start, :counts, :killers)

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @start = start
        @counts = Hash.new(0)
        @killers  = {}
      end

    protected

      # Return counts
      #
      # @return [Hash]
      #
      # @api private
      #
      attr_reader :counts

      # Return start time
      #
      # @return [Time]
      #
      # @api private
      #
      attr_reader :start

      # Return killers
      #
      # @return [Hash]
      #
      # @api private
      #
      attr_reader :killers

    public

      # Count subject
      #
      # @return [self]
      #
      # @api private
      #
      def count_subject
        @counts[:subject] += 1
      end

      # Test for success?
      #
      # @return [true]
      #   if there are subjects and no errors
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def success?
        @counts[:subject].nonzero? && !errors?
      end

      # Count killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def count_killer(killer)
        counter = @killers[killer.mutation.class] ||= Counter.new
        counter.handle(killer)
        self
      end

      # Test for errors
      #
      # @return [true]
      #   if there are errors
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def errors?
        @killers.values.any? do |counter|
          counter.nonzero?
        end
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

    end
  end
end
