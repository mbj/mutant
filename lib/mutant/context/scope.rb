module Mutant
  class Context
    # Scope context for mutation (Class or Module)
    class Scope < self
      include Adamantium::Flat, Concord::Public.new(:scope, :source_path)
      extend AST::Sexp

      NAMESPACE_DELIMITER = '::'.freeze

      # Return AST wrapping mutated node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def root(node)
        nesting.reverse.reduce(node) do |current, scope|
          self.class.wrap(scope, current)
        end
      end

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        scope.name
      end

      # Wrap node into ast node
      #
      # @param [Class, Module] scope
      # @param [Parser::AST::Node] node
      #
      # @return [Parser::AST::Class]
      #   if scope is of kind Class
      #
      # @return [Parser::AST::Module]
      #   if scope is of kind module
      #
      # @api private
      #
      def self.wrap(scope, node)
        name = s(:const, nil, scope.name.split(NAMESPACE_DELIMITER).last.to_sym)
        case scope
        when ::Class
          s(:class, name, nil, node)
        when ::Module
          s(:module, name, node)
        else
          fail "Cannot wrap scope: #{scope.inspect}"
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

      # Return name
      #
      # @return [String]
      #
      # @api private
      #
      def name
        scope.name
      end

      # Return match expressions
      #
      # @return [Enumerable<Expression>]
      #
      # @api private
      #
      def match_expressions
        name_nesting.each_index.reverse_each.map do |index|
          Expression.parse("#{name_nesting.take(index.succ).join(NAMESPACE_DELIMITER)}*")
        end
      end
      memoize :match_expressions

      # Return scope wrapped by context
      #
      # @return [::Module|::Class]
      #
      # @api private
      #
      attr_reader :scope

    private

      # Return nesting of names of scope
      #
      # @return [Array<String>]
      #
      # @api private
      #
      def name_nesting
        scope.name.split(NAMESPACE_DELIMITER)
      end
      memoize :name_nesting

    end # Scope
  end # Context
end # Mutant
