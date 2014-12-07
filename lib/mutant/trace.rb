module Mutant
  # Line tracer
  class Trace
    include Adamantium::Flat, Concord::Public.new(:result ,:coverage)

    private_class_method :new

    # Run block
    #
    # @return [Traces]
    #
    # @api private
    #
    def self.call
      traces = {}
      trace_point = TracePoint.trace(:return, :line) do |point|
        next if point.path.eql?(__FILE__)
        lines = traces[point.path] ||= Set.new
        lines << point.lineno
      end
      result = yield
      trace_point.disable
      new(result, IceNine.deep_freeze(traces))
    end

  end # Trace
end # Mutant
