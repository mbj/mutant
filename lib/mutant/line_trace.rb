# frozen_string_literal: true

module Mutant
  # Line tracer
  module LineTrace
    # Run line tracer
    def self.call(keep, &block)
      lines = []

      result = TracePoint.new(:b_call, :call, :line) do |trace|
        lines << "#{trace.path}:#{trace.lineno}" if keep.call(trace)
      end.enable(&block)

      [result, lines.freeze].freeze
    end
  end # LineTrace
end # Mutant
