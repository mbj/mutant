module Mutant
  class Mutator
    class Node
      # Class for mutations where messages are send to objects
      class Send < self

        handle(Rubinius::AST::Send)

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
          if node.block
            emit_attribute_mutations(:block) 
          end
        end

        # Emit receiver mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver_mutations
          unless to_self? or self_class?
            emit_attribute_mutations(:receiver) 
          end
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
        # @return [Rubinius::AST::Node]
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

        # Check if receiver is self.class
        #
        # @return [true]
        #   if receiver is a "self.class" construct
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #   
        def self_class?
          receiver.kind_of?(Rubinius::AST::Send) && 
          receiver.name == :class                && 
          receiver.receiver.kind_of?(Rubinius::AST::Self)
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
          return unless to_self?
          mutant = dup_node
          mutant.privately = true
          # TODO: Fix rubinius to allow this as an attr_accessor
          mutant.instance_variable_set(:@vcall_style, true)
          emit(mutant)
        end

        class SendWithArguments < self
          
          handle(Rubinius::AST::SendWithArguments)

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            super
            emit_call_remove_mutation
            emit_attribute_mutations(:arguments)
          end

          # Emit transfomr call mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_call_remove_mutation
            array = node.arguments.array
            return unless array.length == 1
            emit(array.first)
          end

        end
      end
    end
  end
end
