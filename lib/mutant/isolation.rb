# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include AbstractType, Adamantium

      abstract_method :error
      abstract_method :next
      abstract_method :value

      # Add error on top of current result
      #
      # @param [Result] error
      #
      # @return [Result]
      def add_error(error)
        ErrorChain.new(error, self)
      end

      # Test for success
      #
      # @return [Boolean]
      def success?
        instance_of?(Success)
      end

      # Succesful result producing value
      class Success < self
        include Concord::Public.new(:value)
      end # Success

      # Unsuccessful result by unexpected exception
      class Exception < self
        include Concord::Public.new(:value)
      end # Error

      # Result when there where many results
      class ErrorChain < Result
        include Concord::Public.new(:value, :next)
      end # ChainError
    end # Result

    # Call block in isolation
    #
    # @return [Result]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
