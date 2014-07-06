module Mutant
  class Matcher
    # Match configuration
    class Config
      include Adamantium, Anima::Update, Anima.new(
        :match_expressions,
        :subject_ignores,
        :subject_selects
      )

      DEFAULT = new(Hash[anima.attribute_names.map { |name| [name, []] }])

      # Return configuration with added value
      #
      # @param [Symbol] attribute
      # @param [Object] value
      #
      # @return [Config]
      #
      # @api private
      #
      def add(attribute, value)
        update(attribute => public_send(attribute).dup << value)
      end

    end # Config
  end # Matcher
end # Mutant
