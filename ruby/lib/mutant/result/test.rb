# frozen_string_literal: true

module Mutant
  module Result
    # Test result
    class Test
      include Anima.new(:job_index, :passed, :runtime, :output)

      alias_method :success?, :passed

      class VoidValue < self
        include Singleton

        # Initialize object
        #
        # @return [undefined]
        def initialize
          super(
            job_index: nil,
            output:    '',
            passed:    false,
            runtime:   0.0
          )
        end
      end # VoidValue

      JSON = Transform::JSON.for_anima(self)
    end # Test
  end # Result
end # Mutant
