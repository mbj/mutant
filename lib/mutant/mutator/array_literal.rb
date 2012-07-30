module Mutant
  class Mutator
    # Mutator for array literals
    class ArrayLiteral < Mutator

    private

      # Append mutants to generator
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
        generator << new_self(dup_body << new_nil)
        mutate_elements(generator)
        mutate_presence(generator)
      end

      # Return array literal body
      #
      # @return [Array]
      #
      # @api private
      #
      def body
        node.body
      end

      # Return duplicated body on each call
      #
      # @return [Array]
      #
      # @api private
      #
      def dup_body
        body.dup
      end

      # Append mutations on element presence
      #
      # @param [#<<] generator
      # 
      # @api private
      #
      # @return [undefined]
      #
      def mutate_presence(generator)
        body.each_index do |index|
          body = dup_body
          body.delete_at(index)
          generator << new_self(body)
        end
      end

      # Append mutations on elements
      #
      # @param [#<<] generator
      # 
      # @api private
      #
      # @return [undefined]
      #
      def mutate_elements(generator)
        body.each_with_index do |child,index|
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
