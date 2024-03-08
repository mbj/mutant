# frozen_string_literal: true

module Mutant
  # An abstract context where mutations can be applied to.
  class Context
    include Adamantium, Anima.new(:scope, :source_path)
    extend AST::Sexp

    def match_expressions
      scope.match_expressions
    end

    # Identification string
    #
    # @return [String]
    def identification
      scope.raw.name
    end

    # Return root node for mutation
    #
    # @return [Parser::AST::Node]
    def root(node)
      scope.nesting.reverse.reduce(node) do |current, raw_scope|
        self.class.wrap(raw_scope, current)
      end
    end

    # Wrap node into ast node
    def self.wrap(raw_scope, node)
      name = s(:const, nil, raw_scope.name.split(Scope::NAMESPACE_DELIMITER).last.to_sym)
      case raw_scope
      when Class
        s(:class, name, nil, node)
      when Module
        s(:module, name, node)
      end
    end
  end # Context
end # Mutant
