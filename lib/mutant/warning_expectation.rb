module Mutant
  # A class to expect some warning message raising on absence of unexpected warnings
  class WarningExpectation
    include Adamantium::Flat, Concord.new(:expected)

    # Error raised on expectation miss
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

      missing    = expected - warnings
      unexpected = warnings - expected

      if unexpected.any?
        fail ExpectationError, unexpected
      end

      if missing.any?
        $stderr.puts("Expected but missing warnings: #{missing}")
      end

      self
    end

  end # WarningExpectation
end # Mutant
