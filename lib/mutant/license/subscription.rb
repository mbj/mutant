# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      include Anima.new(:licensed)

      FORMAT = <<~'MESSAGE'
        %<subscription_name>s subscription:
        Licensed:
        %<licensed>s
      MESSAGE

      FAILURE_FORMAT = <<~'MESSAGE'
        Can not validate %<subscription_name>s license.
        Licensed:
        %<expected>s
        Present:
        %<actual>s
      MESSAGE

      # Load value into subscription
      #
      # @param [Object] value
      #
      # @return [Subscription]
      def self.load(world, value)
        {
          'com' => Commercial,
          'oss' => Opensource
        }.fetch(value.fetch('type'))
          .from_json(value.fetch('contents'))
          .call(world)
      end

      # Subscription self description
      #
      # @return [String]
      def description
        FORMAT % {
          licensed:          licensed.to_a.join("\n"),
          subscription_name: subscription_name
        }
      end

    private

      def failure(expected, actual)
        Either::Left.new(failure_message(expected, actual))
      end

      def success
        Either::Right.new(self)
      end

      def subscription_name
        self.class.name.split('::').last.downcase
      end

      def failure_message(expected, actual)
        FAILURE_FORMAT % {
          actual:            actual.any? ? actual.map(&:to_s).join("\n") : '[none]',
          expected:          expected.map(&:to_s).join("\n"),
          subscription_name: subscription_name
        }
      end
    end # Subscription
  end # License
end # Mutant
