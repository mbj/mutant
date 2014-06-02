# encoding: utf-8

Mutant::Meta::Example.add do
  source 'while true; end'

  mutation 'while true; raise; end'
  mutation 'while false; end'
  mutation 'while nil; end'
  mutation 'nil'
end

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
  source 'until true; foo; bar; end'

  mutation 'until true; bar; end'
  mutation 'until true; foo; end'
  mutation 'until true; end'
  mutation 'until false; foo; bar; end'
  mutation 'until nil;   foo; bar; end'
  mutation 'until true;  foo; nil; end'
  mutation 'until true;  nil; bar; end'
  mutation 'until true;  raise; end'
  mutation 'nil'
end
