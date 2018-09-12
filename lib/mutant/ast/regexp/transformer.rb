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

        REGISTRY = Registry.new

        # Lookup transformer class for regular expression node type
        #
        # @param type [Symbol]
        #
        # @return [Class<Transformer>]
        def self.lookup(type)
          REGISTRY.lookup(type)
        end

        # Register transformer class as responsible for handling node type
        #
        # @param type [Symbol]
        #
        # @return [undefined]
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

          include Concord.new(:expression), Procto.call, AST::Sexp, AbstractType, Adamantium

        private

          # Node with provided children using node type constructed in `type`
          #
          # @param [Object,Parser::AST::Node] child of node
          #
          # @return [Parser::AST::Node]
          def ast(*children)
            s(type, *children)
          end

          # Wrap provided node in a quantifier
          #
          # @param node [Parser::AST::Node]
          #
          # @return [Parser::AST::Node]
          #   quantifier node wrapping provided node if expression is quantified
          #
          # @return [Parser::AST::Node]
          #   original node otherwise
          def quantify(node)
            return node unless expression.quantified?

            Quantifier.to_ast(expression.quantifier).append(node)
          end

          # Transformed children of expression
          #
          # @return [Array<Parser::AST::Node>]
          def children
            expression.expressions.map(&Regexp.method(:to_ast))
          end

          # Node type constructed from token and type of `Regexp::Expression`
          #
          # @return [Symbol]
          def type
            :"#{PREFIX}_#{expression.token}_#{expression.type}"
          end
        end # ExpressionToAST

        # Abstract node transformer
        class ASTToExpression
          include Concord.new(:node), Procto.call, AbstractType, Adamantium

          # Call generic transform method and freeze result
          #
          # @return [Regexp::Expression]
          def call
            transform.freeze
          end

        private

          # Transformation of ast into expression
          #
          # @return [Regexp::Expression]
          abstract_method :transform

          # Transformed children of node
          #
          # @return [Array<Regexp::Expression>]
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

          # Lookup expression token given node type
          #
          # @return [Regexp::Token]
          def expression_token
            self.class::TABLE.lookup(node.type).token
          end

          # Lookup regexp class given node type
          #
          # @return [Class<Regexp::Expression>]
          def expression_class
            self.class::TABLE.lookup(node.type).regexp_class
          end
        end # LookupTable
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
