# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for integer literals
        class Integer < self

          handle(:int)

          children :value

          # Integer overflow boundary probe zones.
          #
          # Each entry pairs a zone boundary with a safe prime sentinel
          # value that falls within that zone. The literal is mutated to
          # the sentinel of the next zone above its absolute value,
          # probing whether consuming code handles values that cross the
          # boundary of the next integer width.
          #
          # Safe primes (p = 2q + 1 where both p and q are prime) are
          # chosen as sentinels because they cannot arise from simple
          # arithmetic (multiplication, bit shifts, masking), providing
          # strong guarantees against coincidental mutation kills. A
          # mutation surviving against a safe prime is a strong signal
          # of missing boundary validation for that integer width.
          #
          # Zone layout:
          #
          #   Zone   Boundary  Sentinel
          #   int8   128       167
          #   uint8  256       467
          #   int16  32768     55_487
          #   uint16 65536     108_503
          #   int32  2^31      2_667_278_543
          #   uint32 2^32      7_980_081_959
          #   int64  2^63      15_508_464_536_481_899_903
          #
          # A literal snaps to the next zone above its absolute value.
          # For example, a literal 100 (below int8 boundary 128) emits
          # sentinel 167. A literal 200 (above int8, below uint8) emits
          # sentinel 467. Values at or above 2^63 emit no sentinel as
          # there is no higher zone to probe.
          #
          # Future versions of mutant will add infrastructure to explain
          # alive mutations, including which overflow zone a surviving
          # sentinel belongs to and what class of bug it indicates.
          class OverflowZone
            include Anima.new(:name, :boundary, :sentinel)
          end

          OVERFLOW_ZONES = [
            OverflowZone.new(name: :int8,   boundary: 2**7,  sentinel: 167),
            OverflowZone.new(name: :uint8,  boundary: 2**8,  sentinel: 467),
            OverflowZone.new(name: :int16,  boundary: 2**15, sentinel: 55_487),
            OverflowZone.new(name: :uint16, boundary: 2**16, sentinel: 108_503),
            OverflowZone.new(name: :int32,  boundary: 2**31, sentinel: 2_667_278_543),
            OverflowZone.new(name: :uint32, boundary: 2**32, sentinel: 7_980_081_959),
            OverflowZone.new(name: :int64,  boundary: 2**63, sentinel: 15_508_464_536_481_899_903)
          ].freeze

        private

          def dispatch
            emit_singletons
            emit_values
            emit_overflow_sentinel
          end

          def emit_overflow_sentinel
            absolute = value.abs

            OVERFLOW_ZONES.each do |zone|
              if absolute < zone.boundary
                emit_type(zone.sentinel)
                return
              end
            end
          end

          def values
            [0, 1, value + 1, value - 1]
          end

        end # Integer
      end # Literal
    end # Node
  end # Mutator
end # Mutant
