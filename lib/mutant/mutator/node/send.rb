module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

        children :receiver, :selector

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
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
          emit(receiver) if receiver
          mutate_receiver
          emit_argument_propagation
          mutate_arguments
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

        NO_PROPAGATE = [ :splat, :block_pass ].to_set

        # Emit argument propagation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_argument_propagation
          return unless arguments.one?
          node = arguments.first
          return if NO_PROPAGATE.include?(node.type)
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
