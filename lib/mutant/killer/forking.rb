module Mutant
  class Killer

#   class Forked < self
#     def initialize(killer, mutation)
#       @killer = killer
#       super(mutation)
#     end

#     def type
#       @killer.type
#     end

#     def run
#       fork do
#         @killer.new(@mutation)
#       end

#       status = Process.wait2.last
#       status.exitstatus.zero?
#     end
#   end

#   class Forking < self
#     include Equalizer.new(:killer)

#     attr_reader :killer

#     def initialize(strategy)
#       @killer = killer
#     end

#     def run(mutation)
#       Forked.new(@killer, mutation)
#     end
#   end
  end
end
