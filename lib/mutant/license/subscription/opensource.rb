# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      class Opensource < self
        SUBSCRIPTION_NAME = 'opensource repository'

        def self.from_json(value)
          new(licensed: value.fetch('repositories').map(&Repository.public_method(:parse)).to_set)
        end

        def call(world)
          Repository.load_from_git(world).bind(&method(:check_subscription))
        end

      private

        def check_subscription(actual)
          if licensed.any? { |repository| actual.any? { |other| repository.allow?(other) } }
            success
          else
            failure(licensed, actual)
          end
        end

      end # Opensource
    end # Subscription
  end # License
end # Mutant
