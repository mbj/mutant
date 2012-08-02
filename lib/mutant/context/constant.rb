module Mutant
  class Context
    # Constant context for mutation (Class or Module)
    class Constant < Context
      include Immutable

      private_class_method :new

      TABLE = {
        ::Class =>  ['class', Rubinius::AST::ClassScope],
        ::Module => ['module', Rubinius::AST::ModuleScope]
      }.freeze

      # Build constant from class or module
      #
      # @param [::Class|::Module] value
      #
      # @return [Constant]
      #
      # @api private
      #
      def self.build(value)
        arguments = TABLE.fetch(value.class) do
          raise ArgumentError, 'Can only build constant mutation scope from class or module'
        end

        new(value, *arguments)
      end

      # Return ast wrapping mutated node
      #
      # @return [Rubinius::AST::Script]
      #
      # @api private
      #
      def root(node)
        root = root_ast
        root.body = @scope_class.new(1, root.name, node)
        Rubinius::AST::Script.new(root)
      end

      # Return unqualified name of constant
      #
      # @return [String]
      #
      # @api private
      #
      def unqualified_name
        name_nesting.last
      end

    private

      # Return constant wrapped by context
      #
      # @return [::Module|::Class]
      #
      # @api private
      #
      attr_reader :constant
      private :constant

      # Initialize object
      #
      # @param [Object] constant
      #
      # @api private
      #
      def initialize(constant, keyword, scope_class)
        @constant, @keyword, @scope_class = constant, keyword, scope_class
      end

      # Return new root ast
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def root_ast
        "#{@keyword} #{qualified_name}; end".to_ast
      end

      # Return qualified name of constant
      #
      # @return [String]
      #
      # @api private
      #
      def qualified_name
        @constant.name
      end

      # Return nesting of names of constant
      #
      # @return [Array<String>]
      #
      # @api private
      #
      def name_nesting
        @constant.name.split('::')
      end

      memoize :unqualified_name
    end
  end
end
