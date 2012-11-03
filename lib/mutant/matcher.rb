module Mutant
  # Abstract matcher to find ASTs to mutate
  class Matcher
    include Adamantium::Flat, Enumerable, AbstractClass
    extend DescendantsTracker

    # Enumerate subjects
    #
    # @api private
    #
    # @return [undefined]
    #
    abstract_method :each

    # Return identification
    #
    # @return [String
    #
    # @api private
    #
    abstract_method :identification

    # Return matcher
    #
    # @param [String] input
    #
    # @return [nil]
    #   returns nil as default implementation
    #
    # @api private
    #
    def self.parse(input)
      nil
    end

    # Return match from string
    #
    # @param [String] input
    #
    # @return [Matcher]
    #   returns matcher input if successful
    #
    # @return [nil]
    #   returns nil otherwise
    #
    def self.from_string(input)
      descendants.each do |descendant|
        matcher = descendant.parse(input)
        return matcher if matcher
      end

      nil
    end
  end
end
