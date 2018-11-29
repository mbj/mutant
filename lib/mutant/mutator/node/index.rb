# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Base mutator for index operations
      class Index < self
        NO_VALUE_RANGE    = (1..-1).freeze
        SEND_REPLACEMENTS = %i[at fetch key?].freeze

        private_constant(*constants(false))

        children :receiver

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_receiver_mutations { |node| !n_nil?(node) }
          emit(receiver)
          emit_send_forms
          emit_drop_mutation
          mutate_indices
        end

        # Emit send forms
        #
        # @return [undefined]
        def emit_send_forms
          return if asgn_left?

          SEND_REPLACEMENTS.each do |selector|
            emit(s(:send, receiver, selector, *indices))
          end
        end

        # Emit mutation `foo[n..-1]` -> `foo.drop(n)`
        #
        # @return [undefined]
        def emit_drop_mutation
          return unless indices.one? && n_irange?(Mutant::Util.one(indices))

          start, ending = *indices.first

          return unless ending.eql?(s(:int, -1))

          emit(s(:send, receiver, :drop, start))
        end

        # Mutate indices
        #
        # @return [undefined]
        def mutate_indices
          children_indices(index_range).each do |index|
            emit_propagation(children.fetch(index)) unless asgn_left?
            delete_child(index)
            mutate_child(index)
          end
        end

        # The index nodes
        #
        # @return [Enumerable<Parser::AST::Node>]
        def indices
          children[index_range]
        end

        class Read < self

          handle :index

        private

          # The range index children can be found
          #
          # @return [Range]
          def index_range
            NO_VALUE_RANGE
          end
        end

        # Mutator for index assignments
        class Assign < self
          REGULAR_RANGE = (1..-2).freeze

          private_constant(*constants(false))

          handle :indexasgn

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            super()

            return if asgn_left?

            emit_index_read
            emit(children.last)
            mutate_child(children.length.pred)
          end

          # Emit index read
          #
          # @return [undefined]
          def emit_index_read
            emit(s(:index, receiver, *children[index_range]))
          end

          # Index indices
          #
          # @return [Range<Integer>]
          def index_range
            if asgn_left?
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
