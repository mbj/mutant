module Mutant
  module AST
    # Node meta information mixin
    class Meta

      # Metadata for optional argument nodes
      class Optarg < self
        UNDERSCORE = '_'.freeze

        children :name, :default_value

        # Test if optarg definition intends to be used
        #
        # @return [Boolean]
        #
        # @api private
        def used?
          !name.to_s.start_with?(UNDERSCORE)
        end
      end # Optarg

    end # Meta
  end # AST
end # Mutant
