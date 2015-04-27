Mutant::Meta::Example.add do
  source 'begin; rescue ExceptionA, ExceptionB => error; true; end'

  singleton_mutations
  mutation 'begin; rescue ExceptionA, ExceptionB; true; end'
  mutation 'begin; rescue self, ExceptionB => error; true; end'
  mutation 'begin; rescue ExceptionA, self => error; true; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; false; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; nil; end'
  mutation 'begin; true; end'

end

Mutant::Meta::Example.add do
  source 'begin; rescue SomeException => error; true; end'

  singleton_mutations
  mutation 'begin; rescue SomeException; true; end'
  mutation 'begin; rescue SomeException => error; false; end'
  mutation 'begin; rescue SomeException => error; nil; end'
  mutation 'begin; rescue self => error; true; end'
  mutation 'begin; true; end'
end

Mutant::Meta::Example.add do
  source 'begin; rescue => error; true end'

  singleton_mutations
  mutation 'begin; rescue => error; false; end'
  mutation 'begin; rescue => error; nil; end'
  mutation 'begin; rescue; true; end'
  mutation 'begin; true; end'
end

Mutant::Meta::Example.add do
  source 'begin; rescue; true end'

  singleton_mutations
  mutation 'begin; rescue; false; end'
  mutation 'begin; rescue; nil; end'
  mutation 'begin; true end'
end
