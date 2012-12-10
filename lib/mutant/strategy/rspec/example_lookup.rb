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

        MAPPING = {
          :<=>  => :spaceship_operator,
          :===  => :case_equality_operator,
          :[]=  => :element_writer,
          :[]   => :element_reader,
          :<=   => :less_than_or_equal_to_operator,
          :>=   => :greater_than_or_equal_to_operator,
          :~@   => :unary_match_operator,
          :+@   => :unary_addition_operator,
          :-@   => :unary_substraction_operator,
          :==   => :equality_operator,
          :'!~' => :nomatch_operator,
          :'!=' => :inequality_operator,
          :=~   => :match_operator,
          :<<   => :left_shift_operator,
          :>>   => :right_shift_operator,
          :**   => :exponentation_operator,
          :*    => :multiplication_operator,
          :%    => :modulo_operator,
          :/    => :division_operator,
          :|    => :bitwise_or_operator,
          :'!'  => :negation_operator,
          :^    => :bitwise_xor_operator,
          :&    => :bitwise_and_operator,
          :<    => :less_than_operator,
          :>    => :greater_than_operator,
          :+    => :addition_operator,
          :-    => :substraction_operator
        }

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
        def mapped_name
          MAPPING[method_name]
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
          return base_path if method_name == :initialize

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
