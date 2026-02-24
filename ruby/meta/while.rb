# frozen_string_literal: true

Mutant::Meta::Example.add :while do
  source 'while true; foo; bar; end'

  singleton_mutations
  mutation 'while true; bar; end'
  mutation 'while true; foo; end'
  mutation 'while true; end'
  mutation 'while false; foo; bar; end'
  mutation 'until true; foo; bar; end'
  mutation 'while true;  foo; nil; end'
  mutation 'while true;  nil; bar; end'
  mutation 'while true;  raise; end'
end

Mutant::Meta::Example.add :while do
  source 'while true; end'

  singleton_mutations
  mutation 'while true; raise; end'
  mutation 'while false; end'
  mutation 'until true; end'
end
