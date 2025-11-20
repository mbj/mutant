# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Generic mutator
      class Generic < self

      private

        def dispatch
          children.each_with_index do |child, index|
            mutate_child(index) if child.instance_of?(::Parser::AST::Node)
          end
        end

      end # Generic
    end # Node
  end # Mutator
end # Mutant
