module Mutant
  module Parallel
    # Job source for parallel execution
    class Source
      include AbstractType

      NoJobError = Class.new(RuntimeError)

      # Next job
      #
      # @return [Object]
      #
      # @raise [NoJobError]
      #   when no next job is available
      abstract_method :next

      # Test if next job is available
      #
      # @return [Boolean]
      abstract_method :next?

      # Job source backed by a finite array
      class Array
        include Concord.new(:jobs)

        # Initialize objecto
        #
        # @return [undefined]
        def initialize(*)
          super

          @next_index = 0
        end

        # Test if next job is available
        #
        # @return [Boolean]
        def next?
          @next_index < jobs.length
        end

        # Next job
        #
        # @return [Object]
        #
        # @raise [NoJobError]
        #   when no next job is available
        def next
          fail NoJobError unless next?
          jobs.fetch(@next_index).tap do
            @next_index += 1
          end
        end

      end # Array
    end # Source
  end # Parallel
end # Mutant
