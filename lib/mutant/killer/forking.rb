module Mutant
  class Killer

    class Forked < self
      def initialize(killer, strategy, mutation)
        @killer = killer
        super(strategy, mutation)
      end

      def type
        @killer.type
      end

      def run
        fork do
          killer = @killer.new(strategy, mutation)
          Kernel.exit(killer.fail? ? 1 : 0)
        end

        status = Process.wait2.last
        status.exitstatus.zero?
      end
    end

    class Forking < self
      include Equalizer.new(:killer)

      attr_reader :killer

      def initialize(killer)
        @killer = killer
      end

      def new(strategy, mutation)
        Forked.new(killer, strategy, mutation)
      end

    end

  end
end
