# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include AbstractType, Adamantium

      NULL_LOG = ''

      private_constant(*constants(false))

      abstract_method :error
      abstract_method :next
      abstract_method :timeout
      abstract_method :value

      # Add error on top of current result
      #
      # @param [Result] error
      #
      # @return [Result]
      def add_error(error)
        ErrorChain.new(error, self)
      end

      # The log captured from integration
      #
      # @return [String]
      def log
        NULL_LOG
      end

      # Test for success
      #
      # @return [Boolean]
      def success?
        instance_of?(Success)
      end

      # Successful result producing value
      class Success < self
        include Concord::Public.new(:value, :log)

        def self.new(_value, _log = '')
          super
        end
      end # Success

      # Unsuccessful result by unexpected exception
      class Exception < self
        include Concord::Public.new(:value)
      end # Error

      # Unsuccessful result by timeout
      class Timeout < self
        include Concord::Public.new(:timeout)
      end # Timeout

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
