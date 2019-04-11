# frozen_string_literal: true

module Mutant
  class Reporter

    # Null reporter
    class Null < self
      include Equalizer.new

      %w[
        alive
        report
        start progress
        warn
      ].each do |name|
        define_method name do |_object|
          self
        end
      end

    end # Null
  end # Reporter
end # Mutant
