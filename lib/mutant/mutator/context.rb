module Mutant
  class Mutator

    # Context to be mutated
    class Context
      include Concord::Public.new(:config, :parent, :input)

      # Return root context for input
      #
      # @param [Config] config
      # @param [Object] input
      #
      # @return [Context]
      #
      # @api private
      #
      def self.root(config, input)
        new(config, nil, input)
      end

    end # Context

  end # Mutation
end # Mutant
