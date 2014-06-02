# encoding: utf-8

Mutant::Meta::Example.add do
  source 'while true; foo; bar; end'

  mutation 'while true; bar; end'
  mutation 'while true; foo; end'
  mutation 'while true; end'
  mutation 'while false; foo; bar; end'
  mutation 'while nil;   foo; bar; end'
  mutation 'while true;  foo; nil; end'
  mutation 'while true;  nil; bar; end'
  mutation 'while true;  raise; end'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'while true; end'

  mutation 'while true; raise; end'
  mutation 'while false; end'
  mutation 'while nil; end'
  mutation 'nil'
end
