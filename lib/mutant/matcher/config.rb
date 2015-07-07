module Mutant
  class Matcher
    # Match configuration
    class Config
      include Adamantium, Anima::Update, Anima.new(
        :match_expressions,
        :subject_ignores
      )

      DEFAULT = new(Hash[anima.attribute_names.map { |name| [name, []] }])

      # Add value to configurable collection
      #
      # @param [Symbol] attribute
      # @param [Object] value
      #
      # @return [Config]
      #
      # @api private
      def add(attribute, value)
        update(attribute => public_send(attribute).dup << value)
      end

    end # Config
  end # Matcher
end # Mutant
