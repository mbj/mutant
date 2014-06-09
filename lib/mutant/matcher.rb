module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium::Flat, Enumerable, AbstractType

    # Enumerate subjects
    #
    # @param [Object] input
    #
    # @return [self]
    #   if block given
    #
    # @return [Enumerable<Subject>]
    #   otherwise
    #
    # @api private
    #
    def self.each(cache, input, &block)
      return to_enum(__method__, cache, input) unless block_given?

      build(cache, input).each(&block)

      self
    end

    # Default matcher build implementation
    #
    # @param [Cache] cache
    # @param [Object] input
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.build(*arguments)
      new(*arguments)
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
