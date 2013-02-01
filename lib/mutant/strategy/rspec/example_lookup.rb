module Mutant
  class Strategy
    class Rspec

      # Example lookup for rspec
      class ExampleLookup
        include Adamantium::Flat, Equalizer.new(:mutation)

        # Perform example lookup
        #
        # @param [Mutation] mutation
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def self.run(mutation)
          new(mutation).spec_files
        end

        # Return mutation
        #
        # @return [Mutation]
        #
        # @api private
        #
        attr_reader :mutation

        # Return spec files
        #
        # @return [Enumerable<String>]
        #
        # @api private
        #
        def spec_files
          expression = glob_expression
          files = Dir[expression]

          if files.empty?
            $stderr.puts("Spec file(s): #{expression.inspect} not found for #{mutation.identification}")
          end

          files
        end
        memoize :spec_files

      private

        # Return source path
        #
        # @return [String]
        #
        # @api private
        #
        def source_path
          mutation.subject.context.source_path
        end

        # Initalize object
        #
        # @param [Mutation] mutation
        #
        # @api private
        #
        def initialize(mutation)
          @mutation = mutation
        end

      end
    end
  end
end
