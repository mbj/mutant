# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      class Commercial < self
        include AbstractType

        def self.from_json(value)
          {
            'individual'   => Individual,
            'organization' => Organization
          }.fetch(value.fetch('type', 'individual')).from_json(value)
        end

        class Organization < self
          SUBSCRIPTION_NAME = 'commercial organization'

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
        end

        class Individual < self
          SUBSCRIPTION_NAME = 'commercial individual'

          class Author
            include Anima.new(:email)

            alias_method :to_s, :email
            public :to_s
          end

          def self.from_json(value)
            new(licensed: value.fetch('authors').to_set { |email| Author.new(email: email) })
          end

          def call(world)
            candidates = candidates(world)

            if (licensed & candidates).any?
              success
            else
              failure(licensed, candidates)
            end
          end

        private

          def candidates(world)
            git_author(world).merge(commit_author(world))
          end

          def git_author(world)
            capture(world, %w[git config --get user.email])
          end

          def commit_author(world)
            capture(world, %w[git show --quiet --pretty=format:%ae])
          end

          def capture(world, command)
            world
              .capture_command(command)
              .either(->(_) { EMPTY_ARRAY }, ->(status) { [Author.new(email: status.stdout.chomp)] })
              .to_set
          end
        end # Individual
      end # Commercial
    end # Subscription
  end # License
end # Mutant
