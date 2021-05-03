# frozen_string_literal: true

module Mutant
  module AST
    module Regexp
      # Regexp bijective mapper
      #
      # Transforms parsed regular expression representation from
      # `Regexp::Expression` instances (provided by `regexp_parser`) into
      # equivalent representations using `Parser::AST::Node`
      class Transformer
        include AbstractType

        REGISTRY = Registry.new(
          ->(type) { fail "No regexp transformer registered for: #{type}" }
        )

        # Lookup transformer class for regular expression node type
        #
        # @param type [Symbol]
        #
        # @return [Class<Transformer>]
        def self.lookup(type)
          REGISTRY.lookup(type)
        end

        def self.register(type)
          REGISTRY.register(type, self)
        end
        private_class_method :register

        # Transform expression
        #
        # @param expression [Regexp::Expression]
        #
        # @return [Parser::AST::Node]
        def self.to_ast(expression)
          self::ExpressionToAST.call(expression)
        end

        # Transform node
        #
        # @param node [Parser::AST::Node]
        #
        # @return [Regexp::Expression]
        def self.to_expression(node)
          self::ASTToExpression.call(node)
        end

        # Abstract expression transformer
        class ExpressionToAST
          PREFIX = :regexp

          include Concord.new(:expression), Procto, AST::Sexp, AbstractType, Adamantium

        private

          def ast(*children)
            s(type, *children)
          end

          def quantify(node)
            return node unless expression.quantified?

            Quantifier.to_ast(expression.quantifier).append(node)
          end

          def children
            expression.map(&Regexp.public_method(:to_ast))
          end

          def type
            :"#{PREFIX}_#{expression.token}_#{expression.type}"
          end
        end # ExpressionToAST

        # Abstract node transformer
        class ASTToExpression
          include Concord.new(:node), Procto, AbstractType, Adamantium

          # Call generic transform method and freeze result
          #
          # @return [Regexp::Expression]
          def call
            transform.freeze
          end

        private

          abstract_method :transform

          def subexpressions
            node.children.map(&Regexp.public_method(:to_expression))
          end
        end # ASTToExpression

        # Mixin for node transformers
        #
        # Helps construct a mapping from Parser::AST::Node domain to
        # Regexp::Expression domain
        module LookupTable
          Mapping = Class.new.include(Concord::Public.new(:token, :regexp_class))

          # Table mapping ast types to object information for regexp domain
          class Table

            # Coerce array of mapping information into structured table
            #
            # @param [Array(Symbol, Array, Class<Regexp::Expression>)]
            #
            # @return [Table]
            def self.create(*rows)
              table = rows.map do |ast_type, token, klass|
                [ast_type, Mapping.new(::Regexp::Token.new(*token), klass)]
              end.to_h

              new(table)
            end

            include Concord.new(:table), Adamantium

            # Types defined by the table
            #
            # @return [Array<Symbol>]
            def types
              table.keys
            end

            # Lookup mapping information given an ast node type
            #
            # @param type [Symbol]
            #
            # @return [Mapping]
            def lookup(type)
              table.fetch(type)
            end
          end # Table

        private

          def expression_token
            self.class::TABLE.lookup(node.type).token
          end

          def expression_class
            self.class::TABLE.lookup(node.type).regexp_class
          end
        end # LookupTable
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
