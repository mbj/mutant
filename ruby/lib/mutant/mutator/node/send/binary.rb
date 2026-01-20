# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to a binary operator
        class Binary < self

          children :left, :operator, :right

          # Pairs of operators where swapping produces equivalent mutants
          # when the right operand is a multiplicative identity (1 or -1).
          MULTIPLICATION_DIVISION_SWAP = {
            %i[* /].freeze => true,
            %i[/ *].freeze => true
          }.freeze

        private

          def dispatch
            emit(left)
            emit_left_mutations
            emit_selector_replacement
            emit(right)
            emit_right_mutations
            emit_not_equality_mutations
          end

          def emit_selector_replacement
            config
              .operators
              .selector_replacements
              .fetch(operator, EMPTY_ARRAY)
              .each do |replacement|
                emit_selector(replacement) unless equivalent_multiplication_division_swap?(replacement)
              end
          end

          # Multiplication and division by 1 or -1 are equivalent operations:
          #   a * 1  == a / 1   (both equal a)
          #   a * -1 == a / -1  (both equal -a)
          #
          # Swapping * <-> / when RIGHT operand is 1 or -1 produces an equivalent
          # mutant that can never be killed, wasting test resources.
          #
          # Note: LEFT operand identity (e.g., 1 * a -> 1 / a) produces different
          # results (a vs 1/a) and should NOT be skipped.
          def equivalent_multiplication_division_swap?(replacement)
            MULTIPLICATION_DIVISION_SWAP.key?([operator, replacement]) && multiplicative_identity?(right)
          end

          def multiplicative_identity?(node)
            return false unless %i[int float].include?(node.type)

            value = Mutant::Util.one(node.children)

            case node.type
            when :int
              value.equal?(1) || value.equal?(-1)
            when :float
              # rubocop:disable Lint/FloatComparison
              value.equal?(1.0) || value.equal?(-1.0)
              # rubocop:enable Lint/FloatComparison
            end
          end

          def emit_not_equality_mutations
            return unless operator.equal?(:'!=')

            emit_not_equality_mutation(:eql?)
            emit_not_equality_mutation(:equal?)
          end

          def emit_not_equality_mutation(new_operator)
            emit(n_not(s(:send, left, new_operator, right)))
          end

        end # Binary

      end # Send
    end # Node
  end # Mutator
end # Mutant
