module Mutant
  class Mutator
    class Node
      module Regexp
        # Character type mutator
        class CharacterType < Node
          map = {
            regexp_digit_type:           :regexp_nondigit_type,
            regexp_hex_type:             :regexp_nonhex_type,
            regexp_space_type:           :regexp_nonspace_type,
            regexp_word_boundary_anchor: :regexp_nonword_boundary_anchor,
            regexp_word_type:            :regexp_nonword_type
          }

          MAP = IceNine.deep_freeze(map.merge(map.invert))

          handle(*MAP.keys)

          # Mutate to invert character type
          #
          # @return [undefined]
          def dispatch
            emit(s(MAP.fetch(node.type)))
          end
        end # CharacterType
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
