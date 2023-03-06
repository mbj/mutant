# frozen_string_literal: true

module Mutant
  module Repository
    class FileRevision
      def self.read(world:, revision:, file_name:)
        world
          .capture_stdout(%w[git show #{revision}:#{file_name}])
      end
    end # FileRevision
  end # Repository
end # Mutant
