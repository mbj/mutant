module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

        RECEIVER_INDEX, SELECTOR_INDEX = 0, 1
        ARGUMENTS_INDEX                = 2..-1.freeze

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
          emit(receiver) if receiver
          mutate_receiver
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
          if arguments.one?
            emit(arguments.first)
          end
          emit_self(receiver, selector)
          children.each_index do |index|
            next if index <= SELECTOR_INDEX
            mutate_child(index)
            delete_child(index)
          end
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
          mutate_child(RECEIVER_INDEX)
        end

        # Emit implicit self mutation
        #
        # @return [undefined]
        #
        # @api rpivate
        #
        def emit_implicit_self
          if receiver.type == :self and !KEYWORDS.include?(selector)
            emit_child_update(RECEIVER_INDEX, nil)
          end
        end

        # Return receiver
        #
        # @return [Parser::Node::AST]
        #
        # @api private
        #
        def receiver
          children[RECEIVER_INDEX]
        end

        # Return selector
        #
        # @return [Symbol]
        #
        # @api private
        #
        def selector
          children[SELECTOR_INDEX]
        end

        # Return arguments
        #
        # @return [Array<Parser::AST::Node>]
        #
        # @api private
        #
        def arguments
          children[ARGUMENTS_INDEX]
        end
        memoize :arguments

      end # Send
    end # Node
  end # Mutator
end # Mutant
