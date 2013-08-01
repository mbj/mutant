# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

        children :receiver, :selector

        SELECTOR_REPLACEMENTS = {
          :send => :public_send,
          :gsub => :sub
        }.freeze

        INDEX_REFERENCE = :[]
        INDEX_ASSIGN    = :[]=
        ASSIGN_SUFFIX   = :'='

        # Base mutator for index operations
        class Index < self

          # Mutator for index references
          class Reference < self

            # Perform dispatch
            #
            # @return [undefined]
            #
            # @api private
            #
            def dispatch
              emit(receiver)
            end

          end # Reference

          # Mutator for index assignments
          class Assign < self

            # Perform dispatch
            #
            # @return [undefined]
            #
            # @api private
            #
            def dispatch
              emit(receiver)
            end

          end # Assign
        end # Index

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          case selector
          when INDEX_REFERENCE
            run(Index::Reference)
          when INDEX_ASSIGN
            run(Index::Assign)
          else
            non_index_dispatch
          end
        end

        # Perform non index dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def non_index_dispatch
          if binary_operator?
            run(Binary)
            return
          end
          normal_dispatch
        end

        # Return arguments
        #
        # @return [Enumerable<Parser::AST::Node>]
        #
        # @api private
        #
        alias_method :arguments, :remaining_children

        # Perform normal, non special case dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def normal_dispatch
          emit_naked_receiver
          emit_selector_mutations
          mutate_receiver
          emit_argument_propagation
          mutate_arguments
        end

        # Emit selector mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_selector_mutations
          replacement = SELECTOR_REPLACEMENTS.fetch(selector) { return }
          emit_selector(replacement)
        end

        # Emit naked receiver mutation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_naked_receiver
          return unless receiver
          op_assign      = OP_ASSIGN.include?(parent_type)
          not_assignable = NOT_ASSIGNABLE.include?(receiver.type)
          return if op_assign and not_assignable
          emit(receiver)
        end

        # Test for binary operator
        #
        # @return [true]
        #   if send is a binary operator
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def binary_operator?
          arguments.one? && BINARY_METHOD_OPERATORS.include?(selector)
        end

        # Mutate arguments
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_arguments
          return if arguments.empty?
          emit_self(receiver, selector)
          remaining_children_with_index.each do |node, index|
            mutate_child(index)
            delete_child(index)
          end
        end

        # Emit argument propagation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_argument_propagation
          return unless arguments.one?
          node = arguments.first
          return if NOT_STANDALONE.include?(node.type)
          emit(arguments.first)
        end

        # Emit receiver mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_receiver
          return unless receiver
          emit_implicit_self
          emit_receiver_mutations
        end

        # Emit implicit self mutation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_implicit_self
          if receiver.type == :self and !KEYWORDS.include?(selector)
            emit_receiver(nil)
          end
        end

      end # Send
    end # Node
  end # Mutator
end # Mutant
