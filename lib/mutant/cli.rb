# frozen_string_literal: true

module Mutant
  # Commandline interface
  module CLI
    # Parse command
    #
    # @return [Command]
    def self.parse(world:, **attributes)
      Command::Root
        .parse(world: world, **attributes)
        .from_right { |message| Command::FailParse.new(world, message) }
    end
  end # CLI
end # Mutant
