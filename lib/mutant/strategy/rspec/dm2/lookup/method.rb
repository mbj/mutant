module Mutant
  class Strategy
    class Rspec
      class DM2
        class Lookup

          # Base class for dm2 style method lookup
          class Method < self

            # Return spec files
            #
            # @return [Enumerable<String>]
            #
            # @api private
            #
            def spec_files
              Dir.glob(glob_expression)
            end
            memoize :spec_files

          private

            # Return base path
            #
            # @return [String]
            #
            # @api private
            #
            def base_path
              "spec/unit/#{Inflecto.underscore(subject.context.name)}"
            end

            # Return method name
            #
            # @return [Symbol]
            #
            # @api private
            #
            def method_name
              subject.name
            end

            # Test if method is public
            #
            # @return [true]
            #   if method is public
            #
            # @return [false]
            #
            # @api private
            #
            def public?
              subject.public?
            end

            # Return expanded name
            #
            # @return [String]
            #
            # @api private
            #
            def expanded_name
              MethodExpansion.run(method_name)
            end

            # Return glob expression
            #
            # @return [String]
            #
            # @api private
            #
            def glob_expression
              public? ? public_glob_expression : private_glob_expression
            end

            # Return public glob expression
            #
            # @return [String]
            #
            # @api private
            #
            def public_glob_expression
              "#{base_path}/#{expanded_name}_spec.rb"
            end

            # Return private glob expression
            #
            # @return [String]
            #
            # @api private
            #
            def private_glob_expression
              "#{base_path}/*_spec.rb"
            end

            # Instance method dm2 style method lookup
            class Instance < self
              handle(Subject::Method::Instance)

            private

              # Return glob expression
              #
              # @return [String]
              #
              # @api private
              #
              def glob_expression
                glob_expression = super
                if method_name == :initialize and !public?
                  "{#{glob_expression},#{base_path}/class_methods/new_spec.rb}"
                else
                  glob_expression
                end
              end

            end # Instance

            # Singleton method dm2 style method lookup
            class Singleton < self
              handle(Subject::Method::Singleton)

            private

              # Return base path
              #
              # @return [String]
              #
              # @api private
              #
              def base_path
                "#{super}/class_methods"
              end

            end # Singleton

          end # Method
        end # Lookup
      end # DM2
    end # Rspec
  end # Strategy
end # Mutant
