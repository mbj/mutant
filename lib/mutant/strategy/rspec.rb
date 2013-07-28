# encoding: utf-8

module Mutant
  class Strategy

    # Rspec strategy base class
    class Rspec < self

      KILLER = Killer::Forking.new(Killer::Rspec)

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def self.setup
        require('./spec/spec_helper.rb')
        self
      end

      # Run all unit specs per mutation
      class Unit < self

        # Return file name pattern for mutation
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def self.spec_files(_mutation)
          Dir['spec/unit/**/*_spec.rb']
        end
      end # Unit

      # Run all integration specs per mutation
      class Integration < self

        # Return file name pattern for mutation
        #
        # @return [Mutation]
        #
        # @api private
        #
        def self.spec_files(_mutation)
          Dir['spec/integration/**/*_spec.rb']
        end
      end # Integration

      # Run all specs per mutation
      class Full < self

        # Return spec files
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def self.spec_files(_mutation)
          Dir['spec/**/*_spec.rb']
        end
      end # Full

    end # Rspec
  end # Strategy
end # Mutant
