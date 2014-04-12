# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for rescue nodes
      class Rescue < Generic

        handle :rescue

      end # Rescue
    end # Node
  end # Mutator
end # Mutant
