# frozen_string_literal: true

module Mutant
  module License
    class Subscription
      class Repository
        include Anima.new(:host, :path)

        REMOTE_REGEXP    = /\A[^\t]+\t(?<url>[^ ]+) \((?:fetch|push)\)\n\z/
        GIT_SSH_REGEXP   = %r{\A[^@]+@(?<host>[^:/]+)[:/](?<path>.+?)(?:\.git)?\z}
        GIT_HTTPS_REGEXP = %r{\Ahttps://(?<host>[^/]+)/(?<path>.+?)(?:\.git)?\z}
        WILDCARD         = '/*'
        WILDCARD_RANGE   = (..-WILDCARD.length)

        private_constant(*constants(false))

        def to_s
          [host, path].join('/')
        end

        def self.load_from_git(world)
          world
            .capture_command(%w[git remote --verbose])
            .fmap { |status| parse_remotes(status.stdout) }
        end

        def self.parse_remotes(input)
          input.lines.map(&method(:parse_remote)).to_set
        end
        private_class_method :parse_remotes

        def self.parse(input)
          host, path = *input.split('/', 2).map(&:downcase)
          new(host: host, path: path)
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

          new(host: match[:host], path: match[:path].downcase)
        end
        private_class_method :parse_url

        def allow?(other)
          other.host.eql?(host) && path_match?(other.path)
        end

      private

        def path_match?(other_path)
          path.eql?(other_path) || wildcard_match?(path, other_path) || wildcard_match?(other_path, path)
        end

        def wildcard_match?(left, right)
          left.end_with?(WILDCARD) && right.start_with?(left[WILDCARD_RANGE])
        end
      end # Repository
    end # Subscription
  end # License
end # Mutant
