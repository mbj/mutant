# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

        children :receiver, :selector

        SELECTOR_REPLACEMENTS = IceNine.deep_freeze(
          send:  [:public_send],
          gsub:  [:sub],
          eql?:  [:equal?],
          :== => [:eql?, :equal?]
        )

        INDEX_REFERENCE = :[]
        INDEX_ASSIGN    = :[]=
        ASSIGN_SUFFIX   = '='.freeze

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
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
          case
          when binary_operator?
            run(Binary)
          when attribute_assignment?
            run(AttributeAssignment)
          else
            normal_dispatch
          end
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
          emit_selector_replacement
          mutate_receiver
          emit_argument_propagation
          mutate_arguments
        end

        # Emit selector replacement
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_selector_replacement
          SELECTOR_REPLACEMENTS.fetch(selector, EMPTY_ARRAY).each do |replacement|
            emit_selector(replacement)
          end
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

        # Test for attribute assignment
        #
        # @return [true]
        #   if node represetns and attribute assignment
        #
        # @return [false]
        #
        # @api private
        #
        def attribute_assignment?
          !BINARY_OPERATORS.include?(selector) && !UNARY_OPERATORS.include?(selector) && assignment? && !mlhs?
        end

        # Mutate arguments
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_arguments
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
          if receiver.type == :self && !KEYWORDS.include?(selector) && !attribute_assignment? && !OP_ASSIGN.include?(parent_type)
            emit_receiver(nil)
          end
        end

        # Test for assignment
        #
        # FIXME: This also returns true for <= operator!
        #
        # @return [true]
        #   if node represents attribute / element assignment
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def assignment?
          selector.to_s[-1] == ASSIGN_SUFFIX
        end

        # Test for mlhs
        #
        # @return [true]
        #   if node is within an mlhs
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def mlhs?
          assignment? && !arguments?
        end

        # Test for empty arguments
        #
        # @return [true]
        #   if arguments are empty
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def arguments?
          arguments.any?
        end

      end # Send
    end # Node
  end # Mutator
end # Mutant
