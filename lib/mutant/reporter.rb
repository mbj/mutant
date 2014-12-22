module Mutant
  # Abstract base class for reporters
  class Reporter
    include AbstractType

    TYPES = IceNine.deep_freeze(%i[
      warn
      start
      trace_report
      trace_status
      kill_report
      kill_status
    ])

    TYPES.each do |name|
      abstract_method(name)
    end

    REPORT_DELAY = 0.0

    # Return report delay
    #
    # FIXME: The need for this API needs to be removed.
    #
    # @return [Float]
    #
    # @api private
    #
    def delay
      REPORT_DELAY
    end

  end # Reporter
end # Mutant
