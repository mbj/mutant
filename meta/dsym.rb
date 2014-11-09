# encoding: utf-8

Mutant::Meta::Example.add do
  source ':"foo#{bar}baz"'

  singleton_mutations
  # TODO: Unparser imperfection two asts with same source.
  mutation s(:dsym, s(:nil), s(:begin, s(:send, nil, :bar)), s(:str, 'baz'))
  mutation s(:dsym, s(:self), s(:begin, s(:send, nil, :bar)), s(:str, 'baz'))
  mutation s(:dsym, s(:str, 'foo'), s(:begin, s(:self)), s(:str, 'baz'))
  mutation s(:dsym, s(:str, 'foo'), s(:begin, s(:nil)), s(:str, 'baz'))
  mutation s(:dsym, s(:str, 'foo'), s(:begin, s(:send, nil, :bar)), s(:nil))
  mutation s(:dsym, s(:str, 'foo'), s(:begin, s(:send, nil, :bar)), s(:self))
end
