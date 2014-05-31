# encoding: utf-8

module Mutant
  class CLI
    # A classifier for input strings
    class Classifier
      include AbstractType, Adamantium::Flat, Concord.new(:cache, :match)

      include Equalizer.new(:identifier)

      SCOPE_NAME_PATTERN = /[A-Za-z][A-Za-z\d_]*/.freeze

      METHOD_NAME_PATTERN = Regexp.union(
        /[A-Za-z_][A-Za-z\d_]*[!?=]?/,
        *OPERATOR_METHODS.map(&:to_s)
      ).freeze

      SCOPE_PATTERN = /
        (?:#{SCOPE_OPERATOR})?#{SCOPE_NAME_PATTERN}
        (?:#{SCOPE_OPERATOR}#{SCOPE_NAME_PATTERN})*
      /x.freeze

      REGISTRY = {}

      # Register classifier
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.register(regexp)
        REGISTRY[regexp] = self
      end
      private_class_method :register

      # Return matchers for input
      #
      # @param [Cache] cache
      # @param [String] pattern
      #
      # @return [Matcher]
      #   if a classifier handles the input
      #
      # @raise [RuntimeError]
      #   otherwise
      #
      # @api private
      #
      def self.run(cache, pattern)
        matches = find(pattern)
        case matches.length
        when 0
          raise Error, "No matcher handles: #{pattern.inspect}"
        when 1
          klass, match = matches.first
          klass.new(cache, match).matcher
        else
          raise Error, "More than one matcher found for: #{pattern.inspect}"
        end
      end

      # Find classifiers
      #
      # @param [String] input
      #
      # @return [Classifier]
      #   if classifier can be found
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.find(input)
        REGISTRY.each_with_object([]) do |(regexp, klass), matches|
          match = regexp.match(input)
          if match
            matches << [klass, match]
          end
        end
      end
      private_class_method :find

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?
        matcher.each(&block)
        self
      end

      # Return identifier
      #
      # @return [String]
      #
      # @api private
      #
      def identifier
        match.to_s
      end
      memoize :identifier

      # Return matcher
      #
      # @return [Matcher]
      #
      # @api private
      #
      abstract_method :matcher
      private :matcher

    end # Classifier
  end # CLI
end # Mutant
