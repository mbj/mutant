# frozen_string_literal: true

module Mutant
  # An abstract context where mutations can be applied to.
  class Context
    include Adamantium, Anima.new(:scope, :source_path)
    extend AST::Sexp

    NAMESPACE_DELIMITER = '::'

    # Return root node for mutation
    #
    # @return [Parser::AST::Node]
    def root(node)
      nesting.reverse.reduce(node) do |current, raw_scope|
        self.class.wrap(raw_scope, current)
      end
    end

    # Identification string
    #
    # @return [String]
    def identification
      scope.raw.name
    end

    # Wrap node into ast node
    def self.wrap(raw_scope, node)
      name = s(:const, nil, raw_scope.name.split(NAMESPACE_DELIMITER).last.to_sym)
      case raw_scope
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

  private

    def name_nesting
      scope.raw.name.split(NAMESPACE_DELIMITER)
    end
    memoize :name_nesting

  end # Context
end # Mutant
