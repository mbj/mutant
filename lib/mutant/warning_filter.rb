module Mutant
  # Stream filter for warnings
  class WarningFilter
    include Equalizer.new(:target)

    WARNING_PATTERN = /\A(?:.+):(?:\d+): warning: (?:.+)\n\z/

    # Initialize object
    #
    # @param [#write] target
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(target)
      @target   = target
      @warnings = []
    end

    # Return filtered warnings
    #
    # @return [Array<String>]
    #
    # @api private
    #
    attr_reader :warnings

    # Return target
    #
    # @return [#write] target
    #
    # @return [undefined]
    #
    # @api private
    #
    attr_reader :target
    protected :target

    # Write message to target filtering warnings
    #
    # @param [String] message
    #
    # @return [self]
    #
    # @api private
    #
    def write(message)
      if WARNING_PATTERN =~ message
        warnings << message
      else
        target.write(message)
      end

      self
    end

    # Use warning filter during block execution
    #
    # @return [Array<String>]
    #
    # @api private
    #
    def self.use
      original = $stderr
      $stderr = filter = new(original)
      yield
      filter.warnings
    ensure
      $stderr = original
    end

  end # WarningFilter
end # Mutant
