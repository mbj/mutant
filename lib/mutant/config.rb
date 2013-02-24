module Mutant
  # The configuration of a mutator run
  class Config
    include Adamantium::Flat, Anima.new(
      :debug, :strategy, :matcher, :filter, :reporter
    )
  end
end
