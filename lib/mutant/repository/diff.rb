# frozen_string_literal: true

module Mutant
  module Repository
    # Diff index between HEAD and a tree reference
    class Diff
      include Adamantium, Anima.new(:world, :to)

      FORMAT = /\A:\d{6} \d{6} [a-f\d]{40} [a-f\d]{40} [ACDMRTUX]\t(.*)\n\z/.freeze

      private_constant(*constants(false))

      class Error < RuntimeError; end

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
        touched_paths
          .fetch(path) { return false }
          .touches?(line_range)
      end

    private

      # Touched paths
      #
      # @return [Hash{Pathname => Path}]
      #
      # rubocop:disable Metrics/MethodLength
      def touched_paths
        pathname = world.pathname
        work_dir = pathname.pwd

        world
          .capture_stdout(%W[git diff-index #{to}])
          .from_right
          .lines
          .map do |line|
            path = parse_line(work_dir, line)
            [path.path, path]
          end
          .to_h
      end
      memoize :touched_paths

      # Parse path
      #
      # @param [Pathname] work_dir
      # @param [String] line
      #
      # @return [Path]
      def parse_line(work_dir, line)
        match = FORMAT.match(line) or fail Error, "Invalid git diff-index line: #{line}"

        Path.new(
          path:  work_dir.join(match.captures.first),
          to:    to,
          world: world
        )
      end

      # Path touched by a diff
      class Path
        include Adamantium, Anima.new(:world, :to, :path)

        DECIMAL = /(?:0|[1-9]\d*)/.freeze
        REGEXP  = /\A@@ -(#{DECIMAL})(?:,(#{DECIMAL}))? \+(#{DECIMAL})(?:,(#{DECIMAL}))? @@/.freeze

        private_constant(*constants(false))

        # Test if diff path touches a line range
        #
        # @param [Range<Integer>] range
        #
        # @return [Boolean]
        def touches?(line_range)
          diff_ranges.any? do |range|
            Range.overlap?(range, line_range)
          end
        end

      private

        # Ranges of hunks in the diff
        #
        # @return [Array<Range<Integer>>]
        def diff_ranges
          world
            .capture_stdout(%W[git diff --unified=0 #{to} -- #{path}])
            .fmap(&Ranges.method(:parse))
            .from_right
        end
        memoize :diff_ranges
      end # Path
    end # Diff
  end # Repository
end # Mutant
