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
      def self.add(&block)
        file = caller.first.split(':in', 2).first
        ALL << DSL.run(file, block)
      end

      Pathname.glob(Pathname.new(__FILE__).parent.parent.parent.join('meta', '**/*.rb'))
        .sort
        .each(&method(:require))
      ALL.freeze

    end # Example

  end # Meta
end # Mutant
