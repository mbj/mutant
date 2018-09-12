# frozen_string_literal: true

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue ExceptionA, ExceptionB => error; true; end'

  singleton_mutations
  mutation 'begin; rescue ExceptionA, ExceptionB; true; end'
  mutation 'begin; rescue self, ExceptionB => error; true; end'
  mutation 'begin; rescue ExceptionA, self => error; true; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; false; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; nil; end'
  mutation 'begin; true; end'

end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue SomeException => error; true; end'

  singleton_mutations
  mutation 'begin; rescue SomeException; true; end'
  mutation 'begin; rescue SomeException => error; false; end'
  mutation 'begin; rescue SomeException => error; nil; end'
  mutation 'begin; rescue self => error; true; end'
  mutation 'begin; true; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue => error; true end'

  singleton_mutations
  mutation 'begin; rescue => error; false; end'
  mutation 'begin; rescue => error; nil; end'
  mutation 'begin; rescue; true; end'
  mutation 'begin; true; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; true end'

  singleton_mutations
  mutation 'begin; rescue; false; end'
  mutation 'begin; rescue; nil; end'
  mutation 'begin; true end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; true; end'

  singleton_mutations
  mutation 'begin; false; end'
  mutation 'begin; nil; end'
end

Mutant::Meta::Example.add :rescue do
  source 'def a; foo; rescue; bar; else; baz; end'

  # Mutate all bodies
  mutation 'def a; nil;  rescue; bar; else; baz; end'
  mutation 'def a; self; rescue; bar; else; baz; end'
  mutation 'def a; foo; rescue; nil;  else; baz; end'
  mutation 'def a; foo; rescue; self; else; baz; end'
  mutation 'def a; foo; rescue; bar; else; nil; end'
  mutation 'def a; foo; rescue; bar; else; self; end'

  # Promote and concat rescue resbody bodies
  mutation 'def a; foo; bar; end'

  # Promote and concat else body
  mutation 'def a; foo; baz; end'

  # Promote rescue body
  mutation 'def a; foo; end'

  # Empty body
  mutation 'def a; end'

  # Failing body
  mutation 'def a; raise; end'

  # Superclass implementation
  mutation 'def a; super; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; ensure; true; end'

  singleton_mutations
  mutation 'begin; rescue; ensure; false; end'
  mutation 'begin; rescue; ensure; nil; end'
end
