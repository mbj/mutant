# frozen_string_literal: true

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
      def call(subject)
        diff.touches?(subject.source_path, subject.source_lines)
      end

    end # SubjectFilter

    # Diff between two objects in repository
    class Diff
      include Adamantium, Anima.new(:config, :from, :to)

      HEAD = 'HEAD'

      # Test if diff changes file at line range
      #
      # @param [Pathname] path
      # @param [Range<Integer>] line_range
      #
      # @return [Boolean]
      #
      # @raise [RepositoryError]
      #   when git command failed
      def touches?(path, line_range)
        return false unless within_working_directory?(path) && tracks?(path)

        command = %W[
          git log
          #{from}...#{to}
          --ignore-all-space
          -L #{line_range.begin},#{line_range.end}:#{path}
        ]

        stdout, status = config.open3.capture2(*command, binmode: true)

        fail RepositoryError, "Command #{command} failed!" unless status.success?

        !stdout.empty?
      end

    private

      # Test if path is tracked in repository
      #
      # FIXME: Cache results, to avoid spending time on producing redundant results.
      #
      # @param [Pathname] path
      #
      # @return [Boolean]
      def tracks?(path)
        command = %W[git ls-files --error-unmatch -- #{path}]
        config.kernel.system(
          *command,
          out: File::NULL,
          err: File::NULL
        )
      end

      # Test if the path is within the current working directory
      #
      # @param [Pathname] path
      #
      # @return [TrueClass, nil]
      def within_working_directory?(path)
        working_directory = config.pathname.pwd
        path.ascend { |parent| return true if working_directory.eql?(parent) }
      end

    end # Diff
  end # Repository
end # Mutant
