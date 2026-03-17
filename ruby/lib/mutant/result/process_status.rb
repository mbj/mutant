# frozen_string_literal: true

module Mutant
  module Result
    # Serializable process status
    #
    # Replaces Process::Status in the result tree with a
    # round-trippable value object.
    class ProcessStatus
      include Anima.new(:exitstatus)

      # Build from a Process::Status object
      #
      # @param [Process::Status] process_status
      #
      # @return [ProcessStatus]
      def self.from_process_status(process_status)
        new(exitstatus: process_status.exitstatus)
      end

      # Test for successful exit
      #
      # @return [Boolean]
      def success?
        exitstatus.equal?(0)
      end
      JSON = Transform::JSON.for_anima(self)
    end # ProcessStatus
  end # Result
end # Mutant
