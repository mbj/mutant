# frozen_string_literal: true

module Mutant
  # Commandline interface
  module CLI
    # Parse command
    #
    # @return [Command]
    def self.parse(arguments:, world:)
      Command::Root.parse(arguments:, world:)
    end
  end # CLI
end # Mutant
