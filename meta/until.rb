# frozen_string_literal: true

Mutant::Meta::Example.add :until do
  source 'until true; foo; bar; end'

  singleton_mutations
  mutation 'until true; bar; end'
  mutation 'until true; foo; end'
  mutation 'until true; end'
  mutation 'until false; foo; bar; end'
  mutation 'until nil; foo; bar; end'
  mutation 'until true; foo; nil; end'
  mutation 'until true; foo; self; end'
  mutation 'until true; nil; bar; end'
  mutation 'until true; self; bar; end'
  mutation 'until true; raise; end'
end
