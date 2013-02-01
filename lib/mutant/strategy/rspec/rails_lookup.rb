module Mutant
  class Strategy
    class Rspec

      # Example lookup for rails rspec
      class RailsLookup < ExampleLookup

        # Return glob expression
        #
        # @return [String]
        #
        # @api private
        #
        def glob_expression
          source_path.gsub('app', 'spec').gsub('.rb', '_spec.rb')
        end

      end
    end
  end
end
