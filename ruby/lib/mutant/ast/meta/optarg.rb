# frozen_string_literal: true

module Mutant
  class AST
    # Node meta information mixin
    module Meta

      # Metadata for optional argument nodes
      class Optarg
        include NamedChildren, Anima.new(:node)

        UNDERSCORE = '_'

        children :name, :default_value

        public :name, :default_value

        # Test if optarg definition intends to be used
        #
        # @return [Boolean]
        def used?
          !name.start_with?(UNDERSCORE)
        end
      end # Optarg

    end # Meta
  end # AST
end # Mutant
