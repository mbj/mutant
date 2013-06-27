module Mutant
  # An AST cache
  class Cache
    # This is explicitly empty! Ask me if you are interested in reasons :D
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
