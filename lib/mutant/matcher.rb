module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium::Flat, Enumerable, AbstractType

    # Default matcher build implementation
    #
    # @param [Env] env
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
    # @return [Enumerable<Subject>]
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
