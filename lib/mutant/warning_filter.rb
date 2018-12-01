# frozen_string_literal: true

module Mutant
  # Stream filter for warnings
  class WarningFilter
    include Equalizer.new(:target)

    WARNING_PATTERN = /\A(?:.+):(?:\d+): warning: (?:.+)\n\z/.freeze

    # Initialize object
    #
    # @param [#write] target
    #
    # @return [undefined]
    def initialize(target)
      @target   = target
      @warnings = []
    end

    # Warnings captured by filter
    #
    # @return [Array<String>]
    attr_reader :warnings

    # Target stream to capture warnings on
    #
    # @return [#write] target
    #
    # @return [undefined]
    attr_reader :target
    protected :target

    # Write message to target filtering warnings
    #
    # @param [String] message
    #
    # @return [self]
    def write(message)
      if WARNING_PATTERN.match?(message)
        warnings << message
      else
        target.write(message)
      end

      self
    end

    # Use warning filter during block execution
    #
    # @return [Array<String>]
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
