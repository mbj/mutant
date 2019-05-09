# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      class Commercial < self
        include Concord.new(:authors)

        class Author
          include Concord.new(:email)

          alias_method :to_s, :email
          public :to_s
        end

        def self.from_json(value)
          new(value.fetch('authors').map(&Author.method(:new)).to_set)
        end

        def apply(world)
          candidates = candidates(world)

          if (authors & candidates).any?
            success
          else
            failure(authors, candidates)
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

        # ignore :reek:UtilityFunction
        def capture(world, command)
          world
            .capture_stdout(command)
            .fmap(&:chomp)
            .fmap(&Author.method(:new))
            .fmap { |value| Set.new([value]) }
            .from_right { Set.new }
        end

      end # Commercial
    end # Subscription
  end # License
end # Mutant
