module Mutant
  class Mutator
    # Mutator on AST blocks
    class Block < Mutator

    private

      # Append mutations to block
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutants(generator)
        mutate_elements(generator)
        mutate_presence(generator)
      end

      # Return block array
      #
      # @return [Array]
      #
      # @api private
      #
      def array
        node.array
      end

      # Return duplicated block array each call
      #
      # @return [Array]
      #
      # @api private
      #
      def dup_array
        array.dup
      end

      # Append mutations on block member presence
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutate_presence(generator)
        array.each_index do |index|
          array = dup_array
          array.delete_at(index)
          generator << new_self(array)
        end
      end

      # Append mutations on block elements
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutate_elements(generator)
        array.each_with_index do |child,index|
          array = dup_array
          Mutator.build(child).each do |mutation|
            array[index]=mutation
            generator << new_self(array)
          end
        end
      end
    end
  end
end
