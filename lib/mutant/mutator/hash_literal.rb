module Mutant
  class Mutator
    # Mutator for hash literal AST nodes
    class HashLiteral < Mutator

    private

      # Append mutants for hash literals
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutants(generator)
        generator << new_nil
        generator << new_self([])
        generator << new_self(array + [new_nil, new_nil])
        mutate_elements(generator)
        mutate_presence(generator)
      end

      # Return hash literal node array
      #
      # @return [Array]
      #
      # @api private
      #
      def array
        node.array
      end

      # Return duplicated literal array on each call
      #
      # @return [Array]
      #
      # @api private
      #
      def dup_array
        array.dup
      end

      # Append mutations on pair presence
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutate_presence(generator)
        pairs = array.each_slice(2).to_a
        pairs.each_index do |index|
          dup_pairs = pairs.dup
          dup_pairs.delete_at(index)
          generator << new_self(dup_pairs.flatten)
        end
      end

      # Append mutations on members
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
