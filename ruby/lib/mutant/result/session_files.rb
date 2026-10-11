# frozen_string_literal: true

module Mutant
  module Result
    # The session files of past runs in .mutant/results/
    class SessionFiles
      include Anima.new(:world)

      DIRECTORY = '.mutant/results'

      # Sessions this version writes gzip compressed, and those earlier
      # versions wrote as plain JSON. The plain ones are listed first,
      # each kind oldest first, as the earlier versions wrote them before
      # this one wrote any.
      PATTERN = '*.json{,.gz}'

      # Sessions a run keeps, and `mutant session gc` keeps by default
      KEEP = 100

      # The session files, oldest first
      #
      # @return [Array<Pathname>]
      def paths
        dir = world.pathname.new(DIRECTORY)

        return EMPTY_ARRAY unless dir.directory?

        dir.glob(PATTERN)
      end

      # Delete all but the most recent sessions
      #
      # A session written alongside this one by a concurrent run may
      # have been deleted by that run already.
      #
      # @param [Integer] keep
      #
      # @return [Array<Pathname>]
      #   the deleted session files
      def prune(keep)
        excess = paths.reverse.drop(keep)

        excess.each do |path|
          path.delete
        rescue Errno::ENOENT
          nil
        end
      end
    end # SessionFiles
  end # Result
end # Mutant
