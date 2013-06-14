module Mutant
  class Mutator
    class Node
      class Arguments < self

        handle(:args)

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_children_mutations
          emit_mlhs_expansion
        end

        # Emit mlhs expansions
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_mlhs_expansion
          mlhs = children.each_with_index.select { |child, index| child.type == :mlhs }
          mlhs.each do |child, index|
            dup_children = children.dup
            dup_children.delete_at(index)
            dup_children.insert(index, *child.children)
            emit_self(*dup_children)
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
