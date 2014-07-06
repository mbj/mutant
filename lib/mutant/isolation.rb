module Mutant
  # Module providing isolationg
  module Isolation
    Error = Class.new(RuntimeError)

    module None

      # Call block in isolation
      #
      # @return [Object]
      #
      # @raise [Error]
      #   if block terminates abnormal
      #
      # @api private
      #
      def self.call(&block)
        block.call
      rescue => exception
        fail Error, exception
      end
    end

    module Fork

      # Call block in isolation
      #
      # This isolation implements the fork strategy.
      # Future strategies will probably use a process pool that can
      # handle multiple mutation kills, in-isolation at once.
      #
      # @return [Object]
      #   returns block execution result
      #
      # @raise [Error]
      #   if block terminates abnormal
      #
      # @api private
      #
      def self.call(&block)
        Parallel.map([block], in_processes: 1) do
          block.call
        end.first
      rescue Parallel::DeadWorker => exception
        fail Error, exception
      end

    end # Fork

  end # Isolator
end # Mutant
