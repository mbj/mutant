module Mutant
  class Reporter
    class Sequence < self
      include Concord.new(:reporters)

      # Minimum reporter delay
      #
      # @return [Float]
      def delay
        reporters.map(&:delay).min
      end

      (superclass.public_instance_methods(false) - public_instance_methods(false)).each do |name|
        define_method(name) do |value|
          reporters.each do |reporter|
            reporter.public_send(name, value)
          end

          self
        end
      end

    end # Sequence
  end # Reporter
end # Mutant
