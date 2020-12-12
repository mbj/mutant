# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Subscription < self
        NAME              = 'subscription'
        SHORT_DESCRIPTION = 'Subscription subcommands'

      private

        def license
          License.call(world)
        end

        class Test < self
          NAME              = 'test'
          SUBCOMMANDS       = [].freeze
          SHORT_DESCRIPTION = 'Silently validates subscription, exits accordingly'

        private

          def execute
            license.right?
          end
        end # Test

        class Show < self
          NAME              = 'show'
          SUBCOMMANDS       = [].freeze
          SHORT_DESCRIPTION = 'Show subscription status'

        private

          def execute
            license.either(method(:unlicensed), method(:licensed))
          end

          def licensed(subscription)
            world.stdout.puts(subscription.description)
            true
          end

          def unlicensed(message)
            world.stderr.puts(message)
            false
          end
        end # Show

        SUBCOMMANDS = [Show, Test].freeze
      end # Subscription
    end # Command
  end # CLI
end # Mutant
