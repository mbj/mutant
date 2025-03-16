# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Base mutator for index operations
      class Index < self
        NO_VALUE_RANGE    = (1..-1)
        SEND_REPLACEMENTS = %i[at fetch key?].freeze

        private_constant(*constants(false))

        children :receiver

      private

        def dispatch
          emit_singletons
          emit_receiver_mutations { |node| !n_nil?(node) }
          emit_type(N_SELF, *children.drop(1))
          emit(receiver)
          emit_send_forms
          emit_drop_mutation
          mutate_indices
        end

        def emit_send_forms
          return if left_op_assignment?

          SEND_REPLACEMENTS.each do |selector|
            emit(s(:send, receiver, selector, *indices))
          end
        end

        def emit_drop_mutation
          return unless indices.one? && n_irange?(Mutant::Util.one(indices))

          start, ending = *indices.first

          return unless ending.eql?(s(:int, -1))

          emit(s(:send, receiver, :drop, start))
        end

        def mutate_indices
          children_indices(index_range).each do |index|
            delete_child(index)
            mutate_child(index)
          end
        end

        def indices
          children[index_range]
        end

        class Read < self

          handle :index

        private

          def index_range
            NO_VALUE_RANGE
          end
        end

        # Mutator for index assignments
        class Assign < self
          REGULAR_RANGE = (1..-2)

          private_constant(*constants(false))

          handle :indexasgn

        private

          def dispatch
            super

            return if left_op_assignment?

            emit_index_read
            emit(children.last)
            mutate_child(children.length.pred)
          end

          def emit_index_read
            emit(s(:index, receiver, *children[index_range]))
          end

          def index_range
            if left_op_assignment?
              NO_VALUE_RANGE
            else
              REGULAR_RANGE
            end
          end
        end # Assign
      end # Index
    end # Node
  end # Mutator
end # Mutant
