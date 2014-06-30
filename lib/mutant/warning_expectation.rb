module Mutant
  # A class to ignore some warning message raising on unexpected warnings
  class WarningExpectation
    include Adamantium::Flat, Concord.new(:ignore)

    # Error raised on unexpected errors
    class ExpectationError < RuntimeError
      include Concord.new(:unexpected)

      # Return exception message
      #
      # @return [String]
      #
      # @api private
      #
      def message
        "Unexpected warnings: #{unexpected.inspect}"
      end

    end # ExpectationError

    # Execute blocks with warning expectations
    #
    # @return [self]
    #
    # @api private
    #
    def execute(&block)
      unexpected = WarningFilter.use(&block) - ignore
      if unexpected.any?
        fail ExpectationError, unexpected
      end
      self
    end

  end # WarningExpectation
end # Mutant
