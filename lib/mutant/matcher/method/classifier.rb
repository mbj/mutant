module Mutant
  class Matcher
    class Method < Matcher
      # A classifier for input strings
      class Classifier
        extend Veritas::Immutable

        TABLE = {
          '.' => Matcher::Method::Singleton,
          '#' => Matcher::Method::Instance
        }

        SCOPE_FORMAT = Regexp.new('\A([^#.]+)(\.|#)(.+)\z')

        private_class_method :new

        # Run classifier
        #
        # @param [String] input
        #
        # @return [Matcher::Method]
        #
        # @api private
        #
        def self.run(input)
          match = SCOPE_FORMAT.match(input)
          raise ArgumentError, "Cannot determine subject from #{input.inspect}" unless match
          new(match).matcher
        end

      public

        # Return method matcher
        #
        # @return [Matcher::Method]
        #
        # @api private
        #
        def matcher
          matcher_class.new(constant_name, method_name)
        end

      private

        # Initialize matcher
        #
        # @param [MatchData] match
        #
        # @api private
        #
        def initialize(match)
          @match = match
        end

        # Return constant name
        #
        # @return [String]
        #
        # @api private
        #
        def constant_name
          @match[1]
        end

        # Return method name
        #
        # @return [String]
        #
        # @api private
        #
        def method_name
          @match[3].to_sym
        end

        # Return scope symbol
        #
        # @return [Symbol]
        #
        # @api private
        #
        def scope_symbol
          @match[2]
        end

        # Return matcher class
        #
        # @return [Class<Matcher>]
        #
        # @api private
        #
        def matcher_class
          TABLE.fetch(scope_symbol)
        end
      end
    end
  end
end
