module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_implicit_self_receiver
          emit_receiver_mutations
          emit_block_mutations
          emit_block_absence_mutation
        end

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          unless to_self?
            emit(receiver)
          end
        end

        # Emit block mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_block_mutations
          emit_attribute_mutations(:block) if node.block
        end

        # Emit receiver mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver_mutations
          emit_attribute_mutations(:receiver)
        end

        # Emit block absence mutation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_block_absence_mutation
          dup = dup_node
          dup.block = nil
          emit(dup)
        end

        # Return receiver AST node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def receiver
          node.receiver
        end

        # Return name of call
        #
        # @return [Symbol]
        #
        # @api private
        #
        def name
          node.name
        end

        # Check if receiver is self
        #
        # @return [true]
        #   if receiver is a Rubinius::AST::Self node
        #
        # @return [false]
        #   return false otherwise
        #
        # @api private
        #
        def to_self?
          receiver.kind_of?(Rubinius::AST::Self)
        end

        # Emit mutation that replaces explicit send to self with implicit send to self
        #
        # @example:
        #
        #   # This class does use Foo#a with explicitly specifing the receiver self.
        #   # But an implicit (privately) call should be used as there is no need for
        #   # specifing en explicit receiver.
        #
        #   class Foo         # Mutation
        #     def print_a     # def print_a
        #       puts self.a   #   puts a
        #     end             # end
        #
        #     def a
        #       :bar
        #     end
        #   end
        #
        #   There will not be any exception so the mutant is not killed and such calls where
        #   implicit receiver should be used will be spotted.
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_implicit_self_receiver
          unless to_self? and !Mutant::KEYWORDS.include?(node.name)
            return
          end

          mutant = dup_node
          mutant.privately = true
          emit(mutant)
        end

      end # Send
    end # Node
  end # Mutator
end # Mutant
