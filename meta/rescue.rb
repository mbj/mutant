# encoding: utf-8

Mutant::Meta::Example.add do
  source 'begin; rescue ExceptionA, ExceptionB => error; true; end'

  mutation 'nil'
  mutation 'begin; rescue ExceptionA, ExceptionB; true; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; false; end'
  mutation 'begin; rescue ExceptionA, ExceptionB => error; nil; end'
  mutation 'begin; rescue ExceptionA => error; true; end'
  mutation 'begin; rescue ExceptionB => error; true; end'
end

Mutant::Meta::Example.add do
  source 'begin; rescue SomeException => error; true; end'

  mutation 'nil'
  mutation 'begin; rescue SomeException; true; end'
  mutation 'begin; rescue SomeException => error; false; end'
  mutation 'begin; rescue SomeException => error; nil; end'
end

Mutant::Meta::Example.add do
  source 'begin; rescue => error; true end'

  mutation 'nil'
  mutation 'begin; rescue => error; false; end'
  mutation 'begin; rescue => error; nil; end'
  mutation 'begin; rescue; true; end'
end

Mutant::Meta::Example.add do
  source 'begin; rescue; true end'

  mutation 'nil'
  mutation 'begin; rescue; false; end'
  mutation 'begin; rescue; nil; end'
end
