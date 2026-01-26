# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Namespace for define mutations
      class Define < self

        # Mapping from AST node types to their type-aware empty/default values
        TYPE_TO_DEFAULT = {
          array: N_EMPTY_ARRAY,
          hash:  N_EMPTY_HASH,
          str:   N_EMPTY_STRING,
          int:   N_ZERO_INTEGER,
          float: N_ZERO_FLOAT
        }.freeze

      private

        def dispatch
          emit_arguments_mutations
          emit_optarg_body_assignments
          emit_body(N_RAISE)
          emit_body(N_ZSUPER)
          emit_type_aware_defaults

          return if !body || ignore?(body)

          emit_body(nil) unless n_begin?(body) && body.children.any?(&method(:ignore?))

          emit_body_mutations
        end

        def emit_type_aware_defaults
          return unless body

          default_node = TYPE_TO_DEFAULT[return_expression.type]

          emit_body(default_node) if default_node
        end

        def return_expression
          if n_begin?(body)
            body.children.last
          else
            body
          end
        end

        def emit_optarg_body_assignments
          arguments.children.each do |argument|
            next unless n_optarg?(argument) && AST::Meta::Optarg.new(node: argument).used?

            emit_body_prepend(s(:lvasgn, *argument))
          end
        end

        def emit_body_prepend(node)
          if body
            emit_body(s(:begin, node, body))
          else
            emit_body(node)
          end
        end

        # Mutator for instance method defines
        class Instance < self

          handle :def

          children :name, :arguments, :body

        end # Instance

        # Mutator for singleton method defines
        class Singleton < self

          handle :defs

          children :subject, :name, :arguments, :body

        end # Singleton

      end # Define
    end # Node
  end # Mutator
end # Mutant
