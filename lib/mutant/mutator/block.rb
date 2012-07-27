module Mutant
  class Mutator
    class Block < Mutator

    private

      def mutants(generator)
        mutate_elements(generator)
        mutate_presence(generator)
      end

      def array
        node.array
      end

      def dup_array
        array.dup
      end

      def mutate_presence(generator)
        array.each_index do |index|
          array = dup_array
          array.delete_at(index)
          generator << new_self(array)
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
