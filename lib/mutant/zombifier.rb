module Mutant
  # Zombifier namespace
  class Zombifier
    include Adamantium::Flat, Concord.new(:namespace)

    # Excluded into zombification
    includes = %w[
      mutant
      morpher
      adamantium
      equalizer
      anima
      concord
    ]

    INCLUDES = %r{\A#{Regexp.union(includes)}(?:/.*)?\z}.freeze

    # Initialize object
    #
    # @param [Symbol] namespace
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(namespace)
      @zombified = Set.new
      @highjack = RequireHighjack.new(Kernel, method(:require))
      super(namespace)
    end

    # Perform zombification of target library
    #
    # @param [String] logical_name
    # @param [Symbol] namespace
    #
    # @api private
    #
    def self.run(logical_name, namespace)
      new(namespace).run(logical_name)
    end

    # Run zombifier
    #
    # @param [String] logical_name
    #
    # @return [undefined]
    #
    # @api private
    #
    def run(logical_name)
      @highjack.infect
      require(logical_name)
    end

    # Test if logical name is subjected to zombification
    #
    # @param [String]
    #
    # @api private
    #
    def include?(logical_name)
      !@zombified.include?(logical_name) && INCLUDES =~ logical_name
    end

    # Require file in zombie namespace
    #
    # @param [String] logical_name
    #
    # @return [self]
    #
    # @api private
    #
    def require(logical_name)
      @highjack.original.call(logical_name)
      return unless include?(logical_name)
      @zombified << logical_name
      file = File.find(logical_name)
      file.zombify(namespace) if file
      self
    end

  end # Zombifier
end # Mutant
