# frozen_string_literal: true

module Mutant
  # An abstract context where mutations can be applied to.
  class Context
    include Adamantium, Anima.new(:constant_scope, :scope, :source_path)

    class ConstantScope
      include AST::Sexp

      class Class < self
        include Anima.new(:const, :descendant)

        def call(node)
          s(:class, const, nil, descendant.call(node))
        end
      end

      class Module < self
        include Anima.new(:const, :descendant)

        def call(node)
          s(:module, const, descendant.call(node))
        end
      end

      class None < self
        include Equalizer.new

        def call(node)
          node
        end
      end
    end

    def match_expressions
      scope.match_expressions
    end

    # Return root node for mutation
    #
    # @return [Parser::AST::Node]
    def root(node)
      constant_scope.call(node)
    end

    # Identification string
    #
    # @return [String]
    def identification
      scope.raw.name
    end

  end # Context
end # Mutant
