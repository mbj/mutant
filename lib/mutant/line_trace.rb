module Mutant
  # Line tracer
  class LineTrace
    include Adamantium::Flat, Concord.new(:contents)

    private_class_method :new

    # Test if trace coveres file at lineno
    #
    # @param [String] file
    # @param [Fixnum] lineno
    #
    # @return [Boolean]
    #
    def cover?(file, lineno)
      contents.fetch(file) { return false }.include?(lineno)
    end

    # Run block
    #
    # @return [Traces]
    #
    # @api private
    #
    def self.call(&block)
      traces = Hash.new { |hash, file| hash[file] = Set.new }
      TracePoint.trace(:return, :line) do |point|
        traces[point.path] << point.lineno
      end.tap(&block).disable
      new(IceNine.deep_freeze(traces))
    end

  end # LineTrace
end # Mutant
