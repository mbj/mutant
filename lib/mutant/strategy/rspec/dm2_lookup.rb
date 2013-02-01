module Mutant
  class Strategy
    class Rspec

      # Example lookup for rspec
      class DM2Lookup < ExampleLookup

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

        EXPANSIONS = {
          /\?\z/ => '_predicate',
          /=\z/  => '_writer',
          /!\z/  => '_bang'
        }

        # Return spec file
        #
        # @return [String]
        #
        # @api private
        #
        def spec_file
          "#{mapped_name || expanded_name}_spec.rb"
        end
        memoize :spec_file

        # Return mapped name
        #
        # @return [Symbol]
        #   if name was mapped
        #
        # @return [nil]
        #   otherwise
        #
        # @api private
        #
        def mapped_name
          OPERATOR_EXPANSIONS[method_name]
        end

        # Return expanded name
        #
        # @return [Symbol]
        #
        # @api private
        #
        def expanded_name
          EXPANSIONS.inject(method_name) do |name, (regexp, expansion)|
            name.to_s.gsub(regexp, expansion)
          end.to_sym
        end

        # Return method name
        #
        # @return [Symbol]
        #
        # @api private
        #
        def method_name
          matcher.method_name
        end

        # Return glob expression
        #
        # @return [String]
        #
        # @api private
        #
        def glob_expression
          base = base_path

          if mutation.subject.matcher.public?
            "#{base}/#{spec_file}"
          else
            "#{base}/*_spec.rb"
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
          "#{spec_path}/#{scoped_path}"
        end
        memoize :base_path

        # Return scoped path
        #
        # @return [String]
        #
        # @api private
        #
        def scoped_path
          "#{Inflecto.underscore(mutation.subject.context.scope.name)}#{scope_append}"
        end

        # Return spec path
        #
        # @return [String]
        #
        # @api private
        #
        def spec_path
          "spec/unit"
        end

      end
    end
  end
end
