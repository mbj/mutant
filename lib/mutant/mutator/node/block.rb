# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Block < self

        handle(:block)

        children :send, :arguments, :body

      private

        def dispatch
          emit_singletons
          emit(send) unless n_lambda?(send)
          emit_send_mutations(&method(:valid_send_mutation?))
          emit_arguments_mutations

          mutate_body
        end

        def mutate_body
          emit_body(nil) unless unconditional_loop?
          emit_body(N_RAISE)

          return unless body
          emit(body) unless body_has_control?
          emit_body_mutations do |node|
            !(n_nil?(node) && unconditional_loop?)
          end

          mutate_body_receiver
        end

        def unconditional_loop?
          send.eql?(s(:send, nil, :loop))
        end

        def body_has_control?
          AST::Structure.for(body.type).each_node(body) do |node|
            return true if n_break?(node) || n_next?(node)
          end

          false
        end

        def mutate_body_receiver
          return if n_lambda?(send) || !n_send?(body)

          body_meta = AST::Meta::Send.new(body)

          emit(s(:send, send, body_meta.selector, *body_meta.arguments))
        end

        def valid_send_mutation?(node)
          return unless n_send?(node)

          last = AST::Meta::Send.new(node).arguments.last

          !last&.type.equal?(:block_pass)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
