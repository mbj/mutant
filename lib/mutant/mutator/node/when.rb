# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Mutator for when nodes
      class When < self

        handle(:when)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          mutate_body
          mutate_conditions
        end

        # Emit condition mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_conditions
          conditions = children.length - 1
          children[0..-2].each_index do |index|
            delete_child(index) if conditions > 1
            mutate_child(index)
          end
        end

        # Emit body mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_body
          mutate_child(children.length - 1)
        end

      end # When
    end # Node
  end # Mutator
end # Mutant
