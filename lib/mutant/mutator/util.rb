module Mutant
  class Mutator
    # Namespace for utility mutators
    class Util < self

      # Run ulitity mutator
      #
      # @param [Object] object
      #
      # @return [Enumerator<Object>]
      #   if no block given
      #
      # @return [self]
      #   otherwise
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
      # @api private
      #
      def new?(generated)
        input != generated
      end

      # Mutators that mutates symbol inputs
      class Symbol < self

        handle(::Symbol)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_new { :"s#{Random.hex_string}" }
        end

      end

      # Mutators that mutates an array of inputs
      class Array < self

        handle(::Array)

        class Presence < Util

        private

          # Emit element presence mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            input.each_index do |index|
              dup = dup_input
              dup.delete_at(index)
              emit(dup)
            end
          end

        end

        class Element < Util

        private

          # Emit mutations
          # 
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            input.each_with_index do |element, index|
              dup = dup_input

              Mutator.each(element).each do |mutation|
                dup[index]=mutation
                emit(dup)
              end
            end
          end

        end

      private

        # Emit mutations
        # 
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          run(Element)
          run(Presence)
          emit([])
        end

      end
    end
  end
end
