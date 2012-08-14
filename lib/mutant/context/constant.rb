module Mutant
  class Context
    # Constant context for mutation (Class or Module)
    class Constant < self
      include Immutable, Abstract

      class Class < self
        SCOPE_CLASS = Rubinius::AST::ClassScope
        KEYWORD     = 'class'.freeze
      end

      class Module < self
        SCOPE_CLASS = Rubinius::AST::ModuleScope
        KEYWORD     = 'module'.freeze
      end

      TABLE = {
        ::Module => Module,
        ::Class => Class
      }.freeze

      # Build constant from class or module
      #
      # @param [String] source_path
      #
      # @param [::Class|::Module] constant
      #
      # @return [Context::Constant]
      #
      # @api private
      #
      def self.build(source_path, constant)
        klass = TABLE.fetch(constant.class) do
          raise ArgumentError, 'Can only build constant mutation scope from class or module'
        end.new(source_path, constant)
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
      def initialize(source_file_path, constant)
        super(source_file_path)
        @constant = constant
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
