module Mutant
  class Context
    # Scope context for mutation (Class or Module)
    class Scope < self
      include Adamantium::Flat, Equalizer.new(:scope, :source_path)

      # Return AST wrapping mutated node
      #
      # @return [Rubinius::AST::Script]
      #
      # @api private
      #
      def root(node)
        nesting.reverse.inject(node) do |current, scope|
          self.class.wrap(scope, current)
        end
      end

      # Return identification
      #
      # @return [String]
      #
      # @ai private
      #
      def identification
        scope.name
      end

      # Wrap node into ast node
      #
      # @param [Class, Module] scope 
      # @param [Rubinius::AST::Node] node
      #
      # @return [Rubinius::AST::Class]
      #   if scope is of kind Class
      #
      # @return [Rubinius::AST::Module]
      #   if scope is of kind module
      #
      # @api private
      #
      def self.wrap(scope, node)
        name = scope.name.split('::').last.to_sym
        case scope
        when ::Class
          ::Rubinius::AST::Class.new(0, name, nil, node)
        when ::Module
          ::Rubinius::AST::Module.new(0, name, node)
        else
          raise "Cannot wrap scope: #{scope.inspect}"
        end
      end

      # Return nesting
      #
      # @return [Enumerable<Class,Module>]
      #
      # @api private
      #
      def nesting
        const = ::Object
        name_nesting.each_with_object([]) do |name, nesting|
          const = const.const_get(name)
          nesting << const
        end
      end
      memoize :nesting

      # Return unqualified name of scope
      #
      # @return [String]
      #
      # @api private
      #
      def unqualified_name
        name_nesting.last
      end

      # Return scope wrapped by context
      #
      # @return [::Module|::Class]
      #
      # @api private
      #
      attr_reader :scope

    private

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
        scope.name
      end

      # Return nesting of names of scope
      #
      # @return [Array<String>]
      #
      # @api private
      #
      def name_nesting
        scope.name.split('::')
      end
      memoize :name_nesting
    end
  end
end
