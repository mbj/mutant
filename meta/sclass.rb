Mutant::Meta::Example.add :sclass do
  source 'class << self; bar; end'

  mutation 'class << self; nil; end'
  mutation 'class << self; self; end'
end

Mutant::Meta::Example.add :sclass do
  source 'class << self; end'
end
