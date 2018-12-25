# frozen_string_literal: true

module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for optional argument nodes
      class Optarg
        include NamedChildren, Concord.new(:node)

        UNDERSCORE = '_'

        children :name, :default_value

        public :name, :default_value

        # Test if optarg definition intends to be used
        #
        # @return [Boolean]
        def used?
          !name.to_s.start_with?(UNDERSCORE)
        end
      end # Optarg

    end # Meta
  end # AST
end # Mutant
