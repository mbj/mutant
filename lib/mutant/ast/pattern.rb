# frozen_string_literal: true

module Mutant
  module AST
    class Pattern
      include Adamantium

      def self.parse(syntax)
        Lexer.call(syntax)
          .lmap(&:display_message)
          .bind(&Parser.public_method(:call))
      end

      class Node < self
        include Anima.new(:type, :attribute, :descendant, :variable)

        DEFAULTS = { attribute: nil, descendant: nil, variable: nil }.freeze

        def initialize(attributes)
          super(DEFAULTS.merge(attributes))
        end

        class Attribute
          include Anima.new(:name, :value)

          class Value
            class Single < self
              include Adamantium, Anima.new(:value)

              def match?(input)
                input.eql?(value)
              end

              def syntax
                value
              end
            end

            class Group < self
              include Adamantium, Anima.new(:values)

              def match?(value)
                values.any? do |attribute_value|
                  attribute_value.match?(value)
                end
              end

              def syntax
                "(#{values.map(&:syntax).join(',')})"
              end
            end # Group
          end # Value

          def match?(node)
            attribute = Structure.for(node.type).attribute(name) and value.match?(attribute.value(node))
          end

          def syntax
            "#{name}=#{value.syntax}"
          end
        end # Attribute

        class Descendant
          include Anima.new(:name, :pattern)

          def match?(node)
            descendant = Structure.for(node.type).descendant(name).value(node)

            !descendant.nil? && pattern.match?(descendant)
          end

          def syntax
            "#{name}=#{pattern.syntax}"
          end
        end # Descendant

        def match?(node)
          fail NotImplementedError if variable

          node.type.eql?(type) \
            && (!attribute || attribute.match?(node)) \
            && (!descendant || descendant.match?(node))
        end

        def syntax
          "#{type}#{pair_syntax}"
        end

      private

        def pair_syntax
          pairs = [*attribute&.syntax, *descendant&.syntax]

          return if pairs.empty?

          "{#{pairs.join(' ')}}"
        end
      end

      class Any < self
        def match?(_node)
          true
        end
      end

      class None < self
        def match?(_node)
          false
        end
      end

      class Deep < self
        include Anima.new(:pattern)

        def match?(node)
          Structure.for(node.type).each_node(node) do |child|
            return true if pattern.match?(child)
          end

          false
        end
      end
    end # Pattern
  end # AST
end # Mutant
