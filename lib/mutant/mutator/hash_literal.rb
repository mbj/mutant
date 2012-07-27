module Mutant
  class Mutator
    class HashLiteral < Mutator

    private

      def mutants(generator)
        generator << new_nil
        generator << new_self([])
        generator << new_self(array + [new_nil, new_nil])
        mutate_elements(generator)
        mutate_presence(generator)
      end

      def array
        node.array
      end

      def dup_array
        array.dup
      end

      def dup_pairs
      end

      def mutate_presence(generator)
        pairs = array.each_slice(2).to_a
        pairs.each_index do |index|
          dup_pairs = pairs.dup
          dup_pairs.delete_at(index)
          generator << new_self(dup_pairs.flatten)
        end
      end

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
