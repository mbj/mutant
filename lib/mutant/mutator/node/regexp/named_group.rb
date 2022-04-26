# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for regexp named capture groups, such as `/(?<foo>bar)/`
        class NamedGroup < Node
          handle(:regexp_named_group)

          children :name

        private

          def dispatch
            return if remaining_children.empty?

            remaining_children_indices.each(&method(:mutate_child))

            # Allows unused captures to be kept and named if they are explicitly prefixed with an
            # underscore, like we allow with unused local variables.
            return if name_underscored?

            emit(s(:regexp_passive_group, *remaining_children))
            emit_name_underscore_mutation
          end

          def emit_name_underscore_mutation
            emit_type("_#{name}", *remaining_children)
          end

          def name_underscored?
            name.start_with?('_')
          end
        end # EndOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
