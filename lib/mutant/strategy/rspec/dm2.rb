module Mutant
  class Strategy
    class Rspec
      # DM2-style strategy
      class DM2 < self

        # Return filename pattern
        #
        # @param [Subject] subject
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(subject)
          Lookup.run(subject)
        end

      end
    end
  end
end
