module Mutant
  class Reporter
    class Sequence < self
      include Concord.new(:reporters)

      %i[warn progress report start].each do |name|
        define_method(name) do |value|
          reporters.each do |reporter|
            reporter.public_send(name, value)
          end

          self
        end
      end

      # Minimum reporter delay
      #
      # @return [Float]
      def delay
        reporters.map(&:delay).min
      end

    end # Sequence
  end # Reporter
end # Mutant
