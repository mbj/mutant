module Mutant
  class Matcher
    # Matcher to find AST for method
    class Method < self
      include Immutable

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
        subject.tap do |subject|
          yield subject if subject
        end

        self
      end

    private

      # Initialize method filter
      #
      # @param [Class|Module] scope
      # @param [Symbol] method_name
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(scope, method_name)
        @scope, @method_name = scope, method_name.to_sym
        @context = Context::Scope.build(@scope, source_path)
      end

      # Return scope
      #
      # @return [Class|Module]
      #
      # @api private
      #
      def scope; @scope; end

      # Return context
      #
      # @return [Context::Scope]
      #
      # @api private
      #
      def context; @context; end

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      def method_name; @method_name; end

      # Return method
      #
      # @return [UnboundMethod]
      #
      # @api private
      #
      abstract_method :method

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

      # Return matched node
      #
      # @return [Rubinis::AST::Node]
      #
      # @api private
      #
      abstract_method :matched_node

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
