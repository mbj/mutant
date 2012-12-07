module Mutant
  class Strategy
    class Rspec

      # Example lookup for rspec
      class ExampleLookup
        include Adamantium::Flat, Equalizer.new(:mutation)

        # Perform example lookup
        #
        # @param [Mutation]
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

        # Return method matcher
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher
          mutation.subject.matcher
        end

        # Return spec file
        #
        # @return [String]
        #
        # @api private
        #
        def spec_file
          matcher.method_name.to_s.
            gsub(/\?\z/, '_predicate').
            gsub(/\=\z/, '_writer').
            gsub(/!\z/, '_bang') + '_spec.rb'
        end
        memoize :spec_file

        # Return glob expression
        #
        # @return [String]
        #
        # @api private
        #
        def glob_expression
          if mutation.subject.matcher.public?
            "#{base_path}/#{spec_file}"
          else
            "#{base_path}/*_spec.rb"
          end
        end

        # Return instance of singleton path appendo
        #
        # @return [String]
        #
        # @api private
        #
        def scope_append
          matcher.kind_of?(Matcher::Method::Singleton) ? '/class_methods' : ''
        end
        memoize :scope_append

        # Return base path
        #
        # @return [String]
        #
        # @api private
        #
        def base_path
          "spec/unit/#{Inflector.underscore(mutation.subject.context.scope.name)}#{scope_append}"
        end
        memoize :base_path

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
