# frozen_string_literal: true

module Mutant
  module AST
    # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/MethodLength
    class Pattern
      class Parser
        def initialize(tokens)
          @tokens        = tokens
          @next_position = 0
        end

        def self.call(tokens)
          new(tokens).__send__(:run)
        end

      private

        def error?
          instance_variable_defined?(:@error)
        end

        def run
          node = catch(:abort) do
            parse_node.tap do
              if next?
                token = peek
                error(
                  message: "Unexpected token: #{token.type}",
                  token:   token
                )
              end
            end
          end

          if error?
            Either::Left.new(@error)
          else
            Either::Right.new(node)
          end
        end

        def parse_node
          structure = parse_node_type

          attribute, descendant = nil

          if optional(:properties_start)
            loop do
              break if optional(:properties_end)

              name = expect(:string)

              name_sym = name.value.to_sym

              if structure.maybe_attribute(name_sym)
                expect(:eq)
                attribute = parse_attribute(name_sym)
                next
              end

              if structure.maybe_descendant(name_sym)
                expect(:eq)
                descendant = parse_descendant(name_sym)
                next
              end

              error(
                message: "Node: #{structure.type} has no property named: #{name_sym}",
                token:   name
              )
            end
          end

          Node.new(
            attribute:  attribute,
            descendant: descendant,
            type:       structure.type
          )
        end

        def parse_attribute(name)
          Node::Attribute.new(
            name:  name,
            value: parse_alternative(
              group_start: method(:parse_attribute_group),
              string:      method(:parse_attribute_value)
            )
          )
        end

        def parse_alternative(alternatives)
          token = peek

          alternatives.fetch(token.type) do
            error(
              message: "Expected one of: #{alternatives.keys.join(',')} but got: #{token.type}",
              token:   token
            )
          end.call
        end

        def parse_descendant(name)
          Node::Descendant.new(
            name:    name,
            pattern: parse_node
          )
        end

        def parse_attribute_group
          expect(:group_start)

          values = []

          loop do
            values << parse_attribute_value
            break unless optional(:delimiter)
          end

          expect(:group_end)

          Node::Attribute::Value::Group.new(values: values)
        end

        def parse_attribute_value
          Node::Attribute::Value::Single.new(value: expect(:string).value.to_sym)
        end

        def error(message:, token: nil)
          @error =
            if token
              "#{message}\n#{token.display_location}"
            else
              message
            end

          throw(:abort)
        end

        def optional(type)
          token = peek

          return unless token&.type.equal?(type)

          advance_position
          token
        end

        def parse_node_type
          token = expect(:string)

          type = token.value.to_sym

          Structure::ALL.fetch(type) do
            error(token: token, message: "Expected valid node type got: #{type}")
          end
        end

        def expect(type)
          token = peek

          unless token
            error(message: "Expected token of type: #{type}, but got no token at all")
          end

          if token.type.eql?(type)
            advance_position
            token
          else
            error(
              token:   token,
              message: "Expected token type: #{type} but got: #{token.type}"
            )
          end
        end

        def peek
          @tokens.at(@next_position)
        end

        def advance_position
          @next_position += 1
        end

        def next?
          @next_position < @tokens.length
        end
      end
    end # Pattern
    # rubocop:enable Metrics/ClassLength
    # rubocop:enable Metrics/MethodLength
  end # AST
end # Mutant
