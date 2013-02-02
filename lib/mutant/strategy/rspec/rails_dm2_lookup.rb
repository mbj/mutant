module Mutant
  class Strategy
    class Rspec

      # Example lookup for Rails DM2 format
      class RailsDM2Lookup < DM2Lookup

      private

        # Return spec path
        #
        # @return [String]
        #
        # @api private
        #
        def spec_path
          source_path =~ /(.*app\/(models|controllers)).*/
          $1.gsub('app', 'spec')
        end
      end
    end
  end
end
