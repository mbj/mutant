# frozen_string_literal: true

Mutant::Meta::Example.add :regexp do
  source '/foo/'

  singleton_mutations

  mutation '//'
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo.bar}n/'

  singleton_mutations

  mutation '/#{foo}n/'
  mutation '/#{nil}n/'
  mutation '/#{self.bar}n/'
  mutation '/#{self}n/'
  mutation '//'
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo}/'

  singleton_mutations

  mutation '/#{self}/'
  mutation '/#{nil}/'
  mutation '//'
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo}#{nil}/'

  singleton_mutations

  mutation '/#{nil}#{nil}/'
  mutation '/#{self}#{nil}/'
  mutation '//'
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '//'

  singleton_mutations

  # match no input
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source 'true if /foo/'

  singleton_mutations
  mutation 'false if /foo/'
  mutation 'nil if /foo/'
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true'

  # match all inputs
  mutation 'true if //'

  # match no input
  mutation 'true if /nomatch\A/'
end

# Case where MRI would accept an expression but regexp_parser not.
Mutant::Meta::Example.add :regexp do
  source '/u{/'

  singleton_mutations
  mutation '//'
  mutation '/nomatch\A/'
end
