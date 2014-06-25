module Mutant
  # Module providing isolationg
  module Isolation
    Error = Class.new(RuntimeError)

    # Call block in isolation
    #
    # This isolation implements the fork strategy.
    # Future strategies will probably use a process pool that can
    # handle multiple mutation kills, in-isolation at once.
    #
    # @return [Object]
    #
    # @raise [Error]
    #
    # @api private
    #
    def self.call(&block)
      Parallel.map([block], in_processes: 1) do
        block.call
      end.first
    end

  end # Isolator
end # Mutant
