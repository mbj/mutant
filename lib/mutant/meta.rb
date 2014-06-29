module Mutant
  # Namespace for mutant metadata
  module Meta
    require 'mutant/meta/example'
    require 'mutant/meta/example/dsl'

    # Mutation example
    class Example

      ALL = []

      # Add example
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.add(&block)
        ALL << DSL.run(block)
      end

      Pathname.glob(Pathname.new(__FILE__).parent.parent.parent.join('meta', '**/*.rb'))
        .sort
        .each(&method(:require))
      ALL.freeze

    end # Example

  end # Meta
end # Mutant
