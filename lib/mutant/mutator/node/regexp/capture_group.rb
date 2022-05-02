# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for regexp capture groups, such as `/(foo)/`
        class CaptureGroup < Node
          handle(:regexp_capture_group)

        private

          def dispatch
            return if children.empty?

            emit(s(:regexp_passive_group, *children))
            children.each_index(&method(:mutate_child))
          end
        end # EndOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
