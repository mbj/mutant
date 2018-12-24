# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Block < self

        handle(:block)

        children :send, :arguments, :body

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit(send) unless n_lambda?(send)
          emit_send_mutations(&method(:valid_send_mutation?))
          emit_arguments_mutations

          mutate_body
        end

        # Emit body mutations
        #
        # @return [undefined]
        def mutate_body
          emit_body(nil)
          emit_body(N_RAISE)

          return unless body
          emit(body) unless body_has_control?
          emit_body_mutations

          mutate_body_receiver
        end

        # Test if body has control structures
        #
        # @return [Boolean]
        def body_has_control?
          AST.find_last_path(body) do |node|
            n_break?(node) || n_next?(node)
          end.any?
        end

        # Mutate method send in body scope of `send`
        #
        # @return [undefined]
        def mutate_body_receiver
          return if n_lambda?(send) || !n_send?(body)

          body_meta = AST::Meta::Send.new(body)

          emit(s(:send, send, body_meta.selector, *body_meta.arguments))
        end

        # Test for valid send mutations
        #
        # @return [true, false, nil]
        def valid_send_mutation?(node)
          return unless n_send?(node)

          last = AST::Meta::Send.new(node).arguments.last

          !last&.type.equal?(:block_pass)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
