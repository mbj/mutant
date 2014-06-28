module Mutant
  module Rspec
    # Rspec test abstraction
    class Test < Mutant::Test
      include Anima.new(:strategy, :example_group, :expression)

      private :strategy

      PREFIX = :rspec

    end # Test
  end # Rspec
end # Mutant
