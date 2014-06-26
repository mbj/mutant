module Mutant
  # An AST cache
  class Cache
    include Equalizer.new

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize
      @cache = {}
    end

    # Return node for file
    #
    # @param [#to_s] path
    #
    # @return [AST::Node]
    #
    # @api private
    #
    def parse(path)
      @cache.fetch(path) do
        @cache[path] = Parser::CurrentRuby.parse(File.read(path))
      end
    end

  end # Cache
end # Mutant
