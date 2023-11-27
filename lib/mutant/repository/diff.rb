# frozen_string_literal: true

module Mutant
  module Repository
    # Diff index between HEAD and a tree reference
    class Diff
      include Adamantium, Anima.new(:world, :to)

      FORMAT = /\A:\d{6} \d{6} [a-f\d]{40} [a-f\d]{40} [ACDMRTUX]\t(.*)\n\z/

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
        touched_path(path) { return false }
          .touches?(line_range)
      end

      def touches_path?(path)
        touched_path(path) { return false }

        true
      end

    private

      def repository_root
        world
          .capture_stdout(%w[git rev-parse --show-toplevel])
          .fmap(&:chomp)
          .fmap(&world.pathname.public_method(:new))
      end

      def touched_path(path, &block)
        touched_paths.from_right { |message| fail Error, message }.fetch(path, &block)
      end

      def touched_paths
        repository_root.bind(&method(:diff_index))
      end
      memoize :touched_paths

      def diff_index(root)
        world
          .capture_stdout(%W[git diff-index #{to}])
          .fmap(&:lines)
          .bind do |lines|
            Mutant
              .traverse(->(line) { parse_line(root, line) }, lines)
              .fmap do |paths|
                paths.to_h { |path| [path.path, path] }
              end
          end
      end

      # rubocop:disable Metrics/MethodLength
      def parse_line(root, line)
        match = FORMAT.match(line)

        if match
          Either::Right.new(
            Path.new(
              path:  root.join(match.captures.first),
              to:    to,
              world: world
            )
          )
        else
          Either::Left.new("Invalid git diff-index line: #{line}")
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Path touched by a diff
      class Path
        include Adamantium, Anima.new(:world, :to, :path)

        DECIMAL = /(?:0|[1-9]\d*)/
        REGEXP  = /\A@@ -(#{DECIMAL})(?:,(#{DECIMAL}))? \+(#{DECIMAL})(?:,(#{DECIMAL}))? @@/

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

        def diff_ranges
          world
            .capture_stdout(%W[git diff --unified=0 #{to} -- #{path}])
            .fmap(&Ranges.public_method(:parse))
            .from_right
        end
        memoize :diff_ranges
      end # Path
    end # Diff
  end # Repository
end # Mutant
