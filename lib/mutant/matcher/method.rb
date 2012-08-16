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
      attr_reader :scope
      private :scope

      # Return context
      #
      # @return [Context::Scope]
      #
      # @api private
      #
      attr_reader :context
      private :context

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      attr_reader :method_name
      private :method_name

      # Return method
      #
      # @return [UnboundMethod]
      #
      # @api private
      #
      abstract_method :method

      # Return node classes this matcher matches
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def node_class
        self.class::NODE_CLASS
      end

      # Check if node is matched
      #
      # @param [Rubinius::AST::Node] node
      #
      # @return [true]
      #   returns true if node matches method
      #
      # @return [false]
      #   returns false if node NOT matches method
      #
      # @api private
      #
      def match?(node)
        node.line  == source_line &&
        node.class == node_class &&
        node.name  == method_name
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
        Subject.new(context, node)
      end
      memoize :subject
    end
  end
end
