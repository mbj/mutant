# frozen_string_literal: true

module Mutant
  module License
    class Subscription

      MESSAGE_FORMAT = <<~'MESSAGE'
        Can not validate %<subscription_name>s license.
        Licensed:
        %<expected>s
        Present:
        %<actual>s
      MESSAGE

      def self.from_json(value)
        {
          'com' => Commercial,
          'oss' => Opensource
        }.fetch(value.fetch('type')).from_json(value.fetch('contents'))
      end

    private

      def failure(expected, actual)
        Either::Left.new(message(expected, actual))
      end

      # ignore :reek:UtilityFunction
      def success
        # masked by soft fail
        Either::Right.new(nil)
      end

      def subscription_name
        self.class.name.split('::').last.downcase
      end

      def message(expected, actual)
        MESSAGE_FORMAT % {
          actual:            actual.any? ? actual.map(&:to_s).join("\n") : '[none]',
          expected:          expected.map(&:to_s).join("\n"),
          subscription_name: subscription_name
        }
      end
    end # Subscription
  end # License
end # Mutant
