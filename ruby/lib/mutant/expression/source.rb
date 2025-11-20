# frozen_string_literal: true

module Mutant
  class Expression
    class Source < self
      include Anima.new(:glob_expression)

      REGEXP = /\Asource:(?<glob_expression>.+)\z/

      def syntax
        "source:#{glob_expression}"
      end

      def matcher(env:)
        Matcher::Chain.new(matchers: find_matchers(env:))
      end

    private

      def find_matchers(env:)
        scope_names(env:).uniq.map do |scope_name|
          Namespace::Recursive.new(scope_name:).matcher(env: nil)
        end
      end

      def scope_names(env:)
        env.world.pathname.glob(glob_expression).flat_map do |path|
          toplevel_consts(env.parser.call(path).node).map(&Unparser.public_method(:unparse))
        end
      end

      def toplevel_consts(node)
        children = node.children

        case node.type
        when :class, :module
          [children.fetch(0)]
        when :begin
          children.flat_map(&method(__method__))
        else
          EMPTY_ARRAY
        end
      end
    end # Source
  end # Expression
end # Mutant
