# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      class Opensource < self
        class Repository
          include Concord.new(:host, :path)

          REMOTE_REGEXP    = /\A[^\t]+\t(?<url>[^ ]+) \((?:fetch|push)\)\n\z/.freeze
          GIT_SSH_REGEXP   = %r{\A[^@]+@(?<host>[^:/]+)[:/](?<path>.+?)(?:\.git)?\z}.freeze
          GIT_HTTPS_REGEXP = %r{\Ahttps://(?<host>[^/]+)/(?<path>.+?)(?:\.git)?\z}.freeze

          private_constant(*constants(false))

          def to_s
            [host, path].join('/')
          end

          def self.parse(input)
            new(*input.split('/', 2))
          end

          def self.parse_remote(input)
            match = REMOTE_REGEXP.match(input) or
              fail "Unmatched remote line: #{input.inspect}"

            parse_url(match[:url])
          end
          private_class_method :parse_remote

          def self.parse_url(input)
            match = GIT_SSH_REGEXP.match(input) || GIT_HTTPS_REGEXP.match(input)

            unless match
              fail "Unmatched git remote URL: #{input.inspect}"
            end

            new(match[:host], match[:path].downcase)
          end
          private_class_method :parse_url
        end

        def self.from_json(value)
          new(
            value
              .fetch('repositories')
              .map(&Repository.public_method(:parse))
              .to_set
          )
        end

        def call(world)
          world
            .capture_stdout(%w[git remote --verbose])
            .fmap(&method(:parse_remotes))
            .bind(&method(:check_subscription))
        end

      private

        def check_subscription(actual)
          if (licensed & actual).any?
            success
          else
            failure(licensed, actual)
          end
        end

        def parse_remotes(input)
          input.lines.map(&Repository.method(:parse_remote)).to_set
        end

      end # Opensource
    end # Subscription
  end # License
end # Mutant
