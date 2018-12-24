# frozen_string_literal: true

module Mutant
  # Base class for code loaders
  class Loader
    include Anima.new(:binding, :kernel, :source, :subject)

    FROZEN_STRING_FORMAT = "# frozen_string_literal: true\n%s"

    private_constant(*constants(false))

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
        FROZEN_STRING_FORMAT % source,
        binding,
        subject.source_path.to_s,
        subject.source_line
      )
    end
  end # Loader
end # Mutant
