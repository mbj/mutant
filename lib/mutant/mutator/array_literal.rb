module Mutant
  class Mutator
    class ArrayLiteral < Mutator

    private

      def mutants(generator)
        generator << new_nil
        generator << new_self([])
        generator << new_self(dup_body << new_nil)
        mutate_elements(generator)
        mutate_element_presence(generator)
      end

      def dup_body
        node.body.dup
      end

      def mutate_element_presence(generator)
        node.body.each_with_index do |child,index|
          body = dup_body
          body.delete_at(index)
          generator << new_self(body)
        end
      end

      def mutate_elements(generator)
        node.body.each_with_index do |child,index|
          body = dup_body
          Mutator.build(child).each do |mutation|
            body[index]=mutation
            generator << new_self(body)
          end
        end
      end
    end
  end
end
