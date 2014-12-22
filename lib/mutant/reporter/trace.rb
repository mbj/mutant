module Mutant
  class Reporter
    # Reporter to trace report calls, used as a spec adapter
    class Trace < self
      include Adamantium::Mutable, Anima.new(*TYPES.map { |name| :"#{name}_calls" })

      # Return new trace reporter
      #
      # @return [Trace]
      #
      # @api private
      #
      def self.new
        super(Hash[anima.attribute_names.map { |name| [name, []] }])
      end

      anima.attribute_names.zip(TYPES).each do |attribute_name, method_name|
        define_method(method_name) do |object|
          public_send(attribute_name) << object
          self
        end
      end

    end # Tracker
  end # reporter
end # Mutant
