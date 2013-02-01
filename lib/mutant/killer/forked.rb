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
  end
end
