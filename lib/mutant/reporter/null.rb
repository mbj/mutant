module Mutant
  class Reporter

    # Null reporter
    class Null < self
      include Equalizer.new

      %w[warn report start progress].each do |name|
        define_method name do |_object|
          self
        end
      end

    end # Null
  end # Reporter
end # Mutant
