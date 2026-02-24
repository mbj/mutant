# frozen_string_literal: true

Mutant::Meta::Example.add :ensure do
  source 'begin; rescue; ensure; true; end'

  singleton_mutations
  mutation 'begin; rescue; ensure; false; end'
  mutation 'begin; rescue; end'
end

Mutant::Meta::Example.add :ensure do
  source 'begin; foo; ensure; bar; end'

  singleton_mutations
  mutation 'begin; nil; ensure; bar; end'
  mutation 'begin; foo; ensure; nil; end'
  mutation 'begin; foo; end'
end

Mutant::Meta::Example.add :ensure do
  source 'begin; foo; ensure; end'

  singleton_mutations
  mutation 'begin; nil; ensure; end'
  mutation 'begin; foo; end'
end

Mutant::Meta::Example.add :ensure do
  source 'begin; ensure; bar; end'

  singleton_mutations
  mutation 'begin; ensure; nil; end'
end
