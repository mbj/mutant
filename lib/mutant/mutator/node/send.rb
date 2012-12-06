module Mutant
  class Mutator
    class Node
      # Class for mutations where messages are send to objects
      class Send < self

        handle(Rubinius::AST::Send)

      private

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
        #   returns true when receiver is a Rubinius::AST::Self node
        #
        # @return [false]
        #   return false otherwise
        #
        # @api private
        #
        def self?
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
          # FIXME: Edge case that is currently not very well undestood
          return if name == :block_given?
          return unless self?
          mutant = dup_node
          mutant.privately = true
          # TODO: Fix rubinius to allow this as an attr_accessor
          mutant.instance_variable_set(:@vcall_style, true)
          emit(mutant)
        end

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_implicit_self_receiver
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
            emit_attribute_mutations(:arguments)
          end

        end
      end
    end
  end
end
