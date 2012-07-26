module Mutant
  class Matcher
    # Matcher to find AST for method
    class Method < Matcher
      include Veritas::Immutable

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
        return to_enum(__method__) unless block_given?
        mutatee.tap do |mutatee|
          yield mutatee if mutatee
        end

        self
      end

      # Return context of matcher
      #
      # @return [Context]
      #   returns the context this matcher matches AST nodes
      #
      # @api private
      #
      def context
        Context::Constant.build(constant)
      end

    private

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      attr_reader :method_name
      private :method_name

      # Return constant name
      #
      # @return [String]
      #
      # @api private
      #
      attr_reader :constant_name
      private :constant_name


      # Initialize method filter
      # 
      # @param [String] constant_name
      # @param [Symbol] method_name
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(constant_name, method_name)
        @constant_name,@method_name = constant_name, method_name
      end

      # Return method
      # 
      # @return [UnboundMethod]
      #
      # @api private
      #
      def method
        Mutant.not_implemented(self)
      end

      # Return node classes this matcher matches
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def node_class
        Mutant.not_implemented(self)
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
        node.line  == source_file_line && 
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

      # Return matched node
      #
      # @return [Rubinis::AST::Node]
      #
      # @api private
      #
      def matched_node
        Mutant.not_implemented(self)
      end

      # Return mutatee
      #
      # @return [Mutatee]
      #
      # @api private
      #
      def mutatee
        node = matched_node
        if node
          Mutatee.new(context,node)
        end
      end

      # Return constant
      #
      # @return [Class|Module]
      #
      # @api private
      #
      def constant
        constant_name.split('::').inject(::Object) do |parent,name|
          parent.const_get(name)
        end
      end

      memoize :mutatee
    end
  end
end
