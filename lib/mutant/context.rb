# frozen_string_literal: true

module Mutant
  # An abstract context where mutations can be applied to.
  class Context
    include Adamantium::Flat, Concord::Public.new(:scope, :source_path)
    extend AST::Sexp

    NAMESPACE_DELIMITER = '::'

    # Return root node for mutation
    #
    # @return [Parser::AST::Node]
    def root(node)
      nesting.reverse.reduce(node) do |current, scope|
        self.class.wrap(scope, current)
      end
    end

    # Identification string
    #
    # @return [String]
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
    def self.wrap(scope, node)
      name = s(:const, nil, scope.name.split(NAMESPACE_DELIMITER).last.to_sym)
      case scope
      when Class
        s(:class, name, nil, node)
      when Module
        s(:module, name, node)
      end
    end

    # Nesting of scope
    #
    # @return [Enumerable<Class,Module>]
    def nesting
      const = Object
      name_nesting.map do |name|
        const = const.const_get(name)
      end
    end
    memoize :nesting

    # Unqualified name of scope
    #
    # @return [String]
    def unqualified_name
      name_nesting.last
    end

    # Match expressions for scope
    #
    # @return [Enumerable<Expression>]
    def match_expressions
      name_nesting.each_index.reverse_each.map do |index|
        Expression::Namespace::Recursive.new(
          scope_name: name_nesting.take(index.succ).join(NAMESPACE_DELIMITER)
        )
      end
    end
    memoize :match_expressions

    # Scope wrapped by context
    #
    # @return [Module|Class]
    attr_reader :scope

  private

    # Nesting of names in scope
    #
    # @return [Array<String>]
    def name_nesting
      scope.name.split(NAMESPACE_DELIMITER)
    end
    memoize :name_nesting

  end # Context
end # Mutant
