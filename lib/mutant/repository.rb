module Mutant
  module Repository
    # Error raised on repository interaction problems
    RepositoryError = Class.new(RuntimeError)

    # Subject filter based on repository diff
    class SubjectFilter
      include Adamantium, Concord.new(:diff)

      # Test if subject was touched in diff
      #
      # @param [Subject] subject
      #
      # @return [Boolean]
      #
      # @api private
      def call(subject)
        diff.touches?(subject.source_path, subject.source_lines)
      end

    end # SubjectFilter

    # Diff between two objects in repository
    class Diff
      include Adamantium, Concord.new(:from, :to)

      HEAD = 'HEAD'.freeze
      private_constant(*constants(false))

      # Create diff from head to revision
      #
      # @return [Diff]
      #
      # @api private
      def self.from_head(to)
        new(HEAD, to)
      end

      # Test if diff changes file at line range
      #
      # @param [Pathname] path
      # @param [Range<Fixnum>] line_range
      #
      # @return [Boolean]
      #
      # @raise [RepositoryError]
      #   when git command failed
      #
      # @api private
      def touches?(path, line_range)
        command = %W[
          git log --pretty=oneline
          #{from}...#{to}
          -L #{line_range.begin},#{line_range.end}:#{path}
        ]

        stdout, status = Open3.capture2(*command, binmode: true)

        fail RepositoryError, "Command #{command} failed!" unless status.success?

        !stdout.empty?
      end

    end # Diff
  end # Repository
end # Mutant
