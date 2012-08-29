module Mutant
  class Matcher
    class Method < self
      # A classifier for input strings
      class Classifier
        include Immutable

        TABLE = {
          '.' => Matcher::Method::Singleton,
          '#' => Matcher::Method::Instance
        }.freeze

        SCOPE_FORMAT = /\A([^#.]+)(\.|#)(.+)\z/.freeze

        # Positions of captured regexp groups
        # Freezing fixnums to avoid their singleton classes are patched.
        SCOPE_NAME_POSITION = 1.freeze
        SCOPE_SYMBOL_POSITION  = 2.freeze
        METHOD_NAME_POSITION   = 3.freeze

        private_class_method :new

        # Run classifier
        #
        # @param [String] input
        #
        # @return [Matcher::Method]
        #   returns matcher when input is in 
        #
        # @return [nil]
        #   returns nil otherwise
        #
        # @api private
        #
        def self.run(input)
          match = SCOPE_FORMAT.match(input)
          return unless match
          new(match).matcher
        end

        # Return method matcher
        #
        # @return [Matcher::Method]
        #
        # @api private
        #
        def matcher
          matcher_class.new(scope, method_name)
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

        # Return scope 
        #
        # @return [Class|Module]
        #
        # @api private
        #
        def scope
          scope_name.gsub(%r(\A::),'').split('::').inject(::Object) do |parent, name|
            parent.const_get(name)
          end
        end

        # Return scope name
        #
        # @return [String]
        #
        # @api private
        #
        def scope_name
          @match[SCOPE_NAME_POSITION]
        end

        # Return method name
        #
        # @return [String]
        #
        # @api private
        #
        def method_name
          @match[METHOD_NAME_POSITION].to_sym
        end

        # Return scope symbol
        #
        # @return [Symbol]
        #
        # @api private
        #
        def scope_symbol
          @match[SCOPE_SYMBOL_POSITION]
        end

        # Return matcher class
        #
        # @return [Class:Mutant::Matcher]
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
