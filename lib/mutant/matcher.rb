module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium::Flat, Enumerable, AbstractType
    extend DescendantsTracker

    # Enumerate subjects
    #
    # @param [Object] input
    #
    # @return [self]
    #   if block given
    #
    # @return [Enumerator<Subject>]
    #
    # @api private
    #
    def self.each(cache, input, &block)
      return to_enum(__method__, cache, input) unless block_given?

      new(cache, input).each(&block)

      self
    end

    # Enumerate subjects
    #
    # @api private
    #
    # @return [self]
    #   if block given
    #
    # @return [Enumerabe<Subject>]
    #   otherwise
    #
    abstract_method :each

    # Return identification
    #
    # @return [String
    #
    # @api private
    #
    abstract_method :identification

  end # Matcher
end # Mutant
