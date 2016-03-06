Mutant::Meta::Example.add :match_current_line do
  source 'true if /foo/'

  singleton_mutations
  mutation 'false if /foo/'
  mutation 'true if //'
  mutation 'nil if /foo/'
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true if /nomatch\A/'
  mutation 'true'
end
