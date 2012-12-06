module Mutant
  class Mutator
    # Namespace for utility mutators
    class Util < self

      # Run ulitity mutator
      #
      # @param [Object]
      #
      # @api private
      #
      def self.each(object, &block)
        return to_enum(__method__, object) unless block_given?

        new(object, block)

        self
      end

      # Test if mutation is new
      #
      # @param [Object] generated
      #
      # @return [true]
      #   if object is new
      #
      # @return [false]
      #   otherwise
      #
      def new?(generated)
        input != generated
      end

      # Mutators that mutates an array of inputs
      class Array < self

      private

        # Emit mutations
        # 
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_element_presence
          emit_element_mutations
          emit([])
        end

        # Emit element mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_element_mutations
          input.each_with_index do |element, index|
            dup = dup_input

            Mutator.each(element).each do |mutation|
              dup[index]=mutation
              emit(dup)
            end
          end
        end

        # Emit element presence mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_element_presence
          input.each_index do |index|
            dup = dup_input
            dup.delete_at(index)
            emit(dup)
          end
        end

      end
    end
  end
end
