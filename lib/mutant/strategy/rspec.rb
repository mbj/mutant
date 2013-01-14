module Mutant
  class Strategy

    # Rspec strategy base class
    class Rspec < self

      KILLER = Killer::Forking.new(Killer::Rspec)

      # Run all unit specs per mutation
      class Unit < self

        # Return file name pattern for mutation
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(mutation)
          Dir['spec/unit/**/*_spec.rb']
        end
      end

      # Run all integration specs per mutation
      class Integration < self

        # Return file name pattern for mutation
        #
        # @return [Mutation]
        #
        # @api private
        #
        def spec_files(mutation)
          Dir['spec/integration/**/*_spec.rb']
        end
      end

      # Run all specs per mutation
      class Full < self

        # Return spec files
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(mutation)
          Dir['spec/**/*_spec.rb']
        end
      end
    end
  end
end
