module Mutant
  # A class to expect some warning message raising on absence of unexpected warnings
  class WarningExpectation
    include Adamantium::Flat, Concord.new(:expected)

    # Error raised on expectation miss
    class ExpectationError < RuntimeError
      include Concord.new(:unexpected, :missing)

      # Return exception message
      #
      # @return [String]
      #
      # @api private
      #
      def message
        "Unexpected warnings: #{unexpected.inspect} missing warnigns: #{missing.inspect}"
      end
    end

    # Execute blocks with warning expectations
    #
    # @return [self]
    #
    # @api private
    #
    def execute(&block)
      warnings = WarningFilter.use do
        block.call
      end
      missing = expected - warnings
      unexpected = warnings - expected
      if missing.any? or unexpected.any?
        fail ExpectationError.new(unexpected, missing)
      end
      self
    end

  end # WarningExpectation
end # Mutant
