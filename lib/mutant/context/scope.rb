module Mutant
  class Context
    # Scope context for mutation (Class or Module)
    class Scope < self
      include Immutable, Abstract

      # Class context for mutation
      class Class < self
        SCOPE_CLASS = Rubinius::AST::ClassScope
        KEYWORD     = 'class'.freeze
      end

      # Module context for mutation
      class Module < self
        SCOPE_CLASS = Rubinius::AST::ModuleScope
        KEYWORD     = 'module'.freeze
      end

      TABLE = {
        ::Module => Module,
        ::Class => Class
      }.freeze

      # Build scope context from class or module
      #
      # @param [String] source_path
      #
      # @param [::Class|::Module] scope
      #
      # @return [Context::Scope]
      #
      # @api private
      #
      def self.build(scope, source_path)
        scope_class = scope.class
        klass = TABLE.fetch(scope_class) do
          raise ArgumentError, "Can only build mutation scope from class or module got: #{scope_class.inspect}"
        end.new(scope, source_path)
      end

      # Return AST wrapping mutated node
      #
      # @return [Rubinius::AST::Script]
      #
      # @api private
      #
      def root(node)
        root = root_ast
        block = Rubinius::AST::Block.new(1, [node])
        root.body = scope_class.new(1, root.name, block)
        script(root)
      end

      # Return unqualified name of scope
      #
      # @return [String]
      #
      # @api private
      #
      def unqualified_name
        name_nesting.last
      end

    private

      # Return scope wrapped by context
      #
      # @return [::Module|::Class]
      #
      # @api private
      #
      attr_reader :scope
      private :scope

      # Initialize object
      #
      # @param [Object] scope
      # @param [String] source_path
      #
      # @api private
      #
      def initialize(scope, source_path)
        super(source_path)
        @scope = scope
      end

      # Return scope AST class
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def scope_class
        self.class::SCOPE_CLASS
      end

      # Return keyword
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def keyword
        self.class::KEYWORD
      end

      # Return new root ast
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def root_ast
        "#{keyword} #{qualified_name}; end".to_ast
      end

      # Return qualified name of scope
      #
      # @return [String]
      #
      # @api private
      #
      def qualified_name
        @scope.name
      end

      # Return nesting of names of scope
      #
      # @return [Array<String>]
      #
      # @api private
      #
      def name_nesting
        @scope.name.split('::')
      end

      memoize :unqualified_name
    end
  end
end
