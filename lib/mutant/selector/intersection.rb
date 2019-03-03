module Mutant
  class Selector
    # Selector that returns the intersection of tests returned by downstreadm selectors
    class Intersection < self
      include Adamantium::Flat, Concord.new(:selectors)

      # Test selected for subject
      #
      # @param [Subject]
      #
      # @return [Maybe<Enumerable<Test>>]
      def call(subject)
        selections = selectors.map { |selector| selector.call(subject) }

        Maybe::Just.new(
          selections.reduce do |left, right|
            left.from_just { return Maybe::Nothing.new } & right.from_just { return Maybe::Nothing.new }
          end
        )
      end
    end # Intersection
  end # Selector
end # Mutant
