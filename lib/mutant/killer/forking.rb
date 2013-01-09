module Mutant
  class Killer

    # Killer that executes other killer in forked environment
    class Forked < self

      # Initialize object
      #
      # @param [Killer] killer
      # @param [Strategy] strategy
      # @param [Mutation] mutation
      #
      # @api private
      #
      def initialize(killer, strategy, mutation)
        @killer = killer
        super(strategy, mutation)
      end

      # Return killer type
      #
      # @return [String]
      #
      # @api private
      #
      def type
        @killer.type
      end

    private

      # Run killer
      #
      # @return [true] 
      #   if mutant was killed
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def run
        fork do
          begin
            killer = @killer.new(strategy, mutation)
            Kernel.exit(killer.fail? ? 1 : 0)
          rescue
            Kernel.exit(1)
          end
        end

        status = Process.wait2.last
        status.exitstatus.zero?
      end
    end

    # A killer that executes other killer in forked environemnts
    class Forking < self
      include Equalizer.new(:killer)

      # Return killer
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killer

      # Initalize killer
      #
      # @param [Killer] killer
      #   the killer that will be used
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(killer)
        @killer = killer
      end

      # Return killer instance
      #
      # @param [Strategy] strategy
      # @param [Mutation] mutation
      #
      # @return [Killer::Forked]
      #
      # @api private
      #
      def new(strategy, mutation)
        Forked.new(killer, strategy, mutation)
      end

    end

  end
end
