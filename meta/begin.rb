Mutant::Meta::Example.add do

  source 'true; false'
  # Mutation of each statement in block
  mutation 'true; true'
  mutation 'false; false'
  mutation 'nil; false'
  mutation 'true; nil'

  # Delete each statement
  mutation 'true'
  mutation 'false'
end

# encoding: utf-8

Mutant::Meta::Example.add do

  source s(:begin, s(:true))
  # Mutation of each statement in block
  mutation s(:begin, s(:nil))
  mutation s(:begin, s(:false))
end
