# frozen_string_literal: true

require 'pathname'

module Mutant
  # Current mutant version
  #
  # See RUST.md for documentation on version loading behavior.
  VERSION =
    if ENV['MUTANT_RUST']
      ENV.fetch('MUTANT_VERSION').freeze
    else
      Pathname
        .new(__dir__)
        .parent
        .parent
        .join('VERSION')
        .read
        .chomp
        .freeze
    end
end # Mutant
