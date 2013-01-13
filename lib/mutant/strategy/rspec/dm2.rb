module Mutant
  class Strategy
    class Rspec
      # DM2-style strategy
      class DM2 < self

        # Return filename pattern
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(mutation)
          ExampleLookup.run(mutation)
        end

      end
    end
  end
end
