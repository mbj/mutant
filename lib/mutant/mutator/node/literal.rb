# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Abstract mutator for literal AST nodes
      class Literal < self
        include AbstractType
      end # Literal
    end # Node
  end # Mutator
end # Mutant
