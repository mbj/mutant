module Mutant
  class Matcher
    class Method < Matcher
      # A classifier for input strings
      class Classifier
        TABLE = {
          '.' => Matcher::Method::Singleton,
          '#' => Matcher::Method::Instance
        }

        SCOPE_FORMAT = Regexp.new('\A([^#.]+)(\.|#)(.+)\z')

        private_class_method :new

        def self.run(input)
          match = SCOPE_FORMAT.match(input)
          raise ArgumentError,"Cannot determine subject from #{input.inspect}" unless match
          new(match).matcher
        end

        def matcher
          scope.new(constant_name,method_name)
        end

      private

        def initialize(match)
          @match = match
        end

        def constant_name
          @match[1]
        end

        def method_name
          @match[3]
        end

        def scope_symbol
          @match[2]
        end

        def scope
          TABLE.fetch(scope_symbol)
        end
      end
    end
  end
end
