# encoding: utf-8

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
