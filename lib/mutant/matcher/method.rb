module Mutant
  class Matcher
    # Matcher for subjects that are a specific method
    class Method < self
      include Adamantium::Flat, Equalizer.new(:identification)

      # Parse a method string into filter
      #
      # @param [String] input
      #
      # @return [Matcher::Method]
      #
      # @api private
      #
      def self.parse(input)
        Classifier.run(input)
      end

      # Methods within rbx kernel directory are precompiled and their source 
      # cannot be accessed via reading source location
      BLACKLIST = /\Akernel\//.freeze

      # Enumerate matches
      #
      # @return [Enumerable]
      #   returns enumerable when no block given
      #
      # @return [self]
      #   returns self when block given
      #
      # @api private
      # 
      def each(&block)
        return to_enum unless block_given?

        return self if skip?

        subject.tap do |subject|
          yield subject if subject
        end

        self
      end

      # Return method
      #
      # @return [UnboundMethod, Method]
      #
      # @api private
      #
      attr_reader :method

      # Return scope
      #
      # @return [Class|Module]
      #
      # @api private
      #
      attr_reader :scope

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      def method_name
        method.name
      end

      # Test if method is public
      #
      # @return [true]
      #   if method is public
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      abstract_method :public?

    private

      # Initialize method filter
      #
      # @param [Class|Module] scope
      # @param [Method, UnboundMethod] method
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(scope, method)
        @scope, @method = scope, method
        # FIXME: cache public private should not be needed, loader should not override visibility! (But does currently) :(
        public?
      end

      # Test if method is skipped
      #
      # @return [true]
      #   true and print warning if location must be filtered
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def skip?
        location = source_location
        if location.nil? or BLACKLIST.match(location.first)
          $stderr.puts "#{method.inspect} does not have valid source location so mutant is unable to emit matcher"
          return true
        end

        false
      end

      # Return context
      #
      # @return [Context::Scope]
      #
      # @api private
      #
      def context
        Context::Scope.new(scope, source_path)
      end

      # Return full ast
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def ast
        File.read(source_path).to_ast
      end

      # Return path to source
      #
      # @return [String]
      #
      # @api private
      #
      def source_path
        source_location.first
      end

      # Return source file line
      #
      # @return [Integer]
      #
      # @api private
      #
      def source_line
        source_location.last
      end

      # Return source location
      #
      # @return [Array]
      #
      # @api private
      #
      def source_location
        method.source_location
      end

      # Return subject
      #
      # @return [Subject]
      #   returns subject if there is a matched node
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def subject
        node = matched_node
        return unless node
        Subject.new(self, context, node)
      end
      memoize :subject

      # Return matched node
      #
      # @return [Rubinus::AST::Node]
      #
      # @api private
      #
      def matched_node
        last_match = nil
        ast.walk do |predicate, node|
          last_match = node if match?(node)
          predicate
        end
        last_match
      end
    end
  end
end
