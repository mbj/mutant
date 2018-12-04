# frozen_string_literal: true

module Mutant
  # Base class for code loaders
  class Loader
    include Anima.new(:binding, :kernel, :source, :subject)

    # Call loader
    #
    # @return [self]
    def self.call(*arguments)
      new(*arguments).call
    end

    # Call loader
    #
    # One off the very few valid uses of eval
    #
    # @return [undefined]
    def call
      kernel.eval(
        source,
        binding,
        subject.source_path.to_s,
        subject.source_line
      )
    end
  end # Loader
end # Mutant
