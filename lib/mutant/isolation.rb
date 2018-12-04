# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include AbstractType

      abstract_method :value
      abstract_method :error

      # Test for success
      #
      # @return [Boolean]
      def success?
        instance_of?(Success)
      end

      class Success < self
        include Concord::Public.new(:value)
      end # Success

      class Error < self
        include Concord::Public.new(:error)
      end # Error
    end # Result

    # Call block in isolation
    #
    # @return [Result]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
