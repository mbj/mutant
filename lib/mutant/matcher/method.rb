module Mutant
  class Matcher
    # A filter for methods
    class Method < Matcher
      # Return constant name 
      #
      # @return [String]
      #
      # @api private
      #
      attr_reader :constant_name

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      attr_reader :method_name

      # Initialize method filter
      # 
      # @param [String] constant_name
      # @param [String] method_name
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(constant_name, method_name)
        @constant_name, @method_name = constant_name, method_name
      end

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
      def each
        return to_enum(__method__) unless block_given?
        yield root_node
        self
      end

      # Check if node is matched 
      #
      # @param [Rubinius::AST::Node]
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
        node.line == source_file_line && node_class == node.class && node.name.to_s == method_name
      end

    private

      # Return method
      # 
      # @return [UnboundMethod]
      #
      # @api private
      #
      def method
        Mutant.not_implemente(self)
      end

      # Return node classes this matcher matches
      #
      # @return [Enumerable]
      #
      # @api private
      #
      def node_classes
        Mutant.not_implemented(self)
      end

      # Return root node
      #
      # @return [Rubinus::AST::Node]
      #
      # @api private
      #
      def root_node
        root_node = nil
        ast.walk do |_, node|
          root_node = node if match?(node)
          true
        end
        root_node
      end

      # Return full ast
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def ast
        File.read(source_filename).to_ast
      end

      # Return source filename
      #
      # @return [String]
      #
      # @api private
      #
      def source_filename
        source_location.first
      end

      # Return source file line
      #
      # @return [Integer]
      #
      # @api private
      #
      def source_file_line
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

      # Return constant
      #
      # @return [Class|Module]
      #
      # @api private
      #
      def constant
        constant_name.split(/::/).inject(Object) do |context, name|
          context.const_get(name)
        end
      end
    end
  end
end
