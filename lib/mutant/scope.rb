# frozen_string_literal: true

module Mutant
  # Class or Module bound to an exact expression
  class Scope
    include Adamantium, Anima.new(:raw, :expression)

    NAMESPACE_DELIMITER = '::'

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
      raw.name.split(NAMESPACE_DELIMITER)
    end
    memoize :name_nesting

  end # Scope
end # Mutant
