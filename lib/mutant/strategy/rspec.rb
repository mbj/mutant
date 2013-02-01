module Mutant
  class Strategy

    # Rspec strategy base class
    class Rspec < self

      KILLER = Killer::Forking.new(Killer::Rspec)

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

      # Run all unit specs per mutation
      class Unit < self

        # Return file name pattern for mutation
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(mutation)
          ['spec/unit']
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

      # Run model/controller specs per mutation
      class Rails < self

        # Return spec files
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files(mutation)
          Dir['spec/models/*_spec.rb', 'spec/controllers/*_spec.rb']
        end
      end
    end
  end
end
