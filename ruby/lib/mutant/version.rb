# frozen_string_literal: true

require 'pathname'

module Mutant
  # Current mutant version
  VERSION =
    Pathname
      .new(__dir__)
      .parent
      .parent
      .join('VERSION')
      .read
      .chomp
      .freeze
end # Mutant
