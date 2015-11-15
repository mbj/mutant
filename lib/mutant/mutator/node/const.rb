module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle const nodes
      class Const < self

        handle(:const)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons unless parent_node && n_const?(parent_node)
          emit_type(nil, *children.drop(1))
          children.each_with_index do |child, index|
            mutate_child(index) if child.instance_of?(::Parser::AST::Node)
          end
        end

      end # Const
    end # Node
  end # Mutator
end # Mutant
