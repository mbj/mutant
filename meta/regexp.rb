# frozen_string_literal: true

Mutant::Meta::Example.add :regexp do
  source '/foo/'

  singleton_mutations
  regexp_mutations
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo.bar}n/'

  singleton_mutations
  regexp_mutations

  mutation '/#{foo}n/'
  mutation '/#{self.bar}n/'
  mutation '/#{nil}n/'
  mutation '/#{self}n/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo}/'

  singleton_mutations
  regexp_mutations

  mutation '/#{self}/'
  mutation '/#{nil}/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo}#{nil}/'

  singleton_mutations
  regexp_mutations

  mutation '/#{nil}#{nil}/'
  mutation '/#{self}#{nil}/'
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
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true'

  # match all inputs
  mutation 'true if //'

  # match no input
  mutation 'true if /nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '/(?(1)(foo)(bar))/'

  singleton_mutations
  regexp_mutations

  mutation '/(?(1)(?:foo)(bar))/'
  mutation '/(?(1)(foo)(?:bar))/'
end

# MRI accepts this regex but `regexp_parser` does not.
# See: https://github.com/ammar/regexp_parser/issues/75
Mutant::Meta::Example.add :regexp do
  source '/\xA/'

  singleton_mutations
  mutation '//'
  mutation '/nomatch\A/'
end

# MRI accepts this regex but `regexp_parser` does not.
# See: https://github.com/ammar/regexp_parser/issues/76
Mutant::Meta::Example.add :regexp do
  source '/(?<æ>.)/'

  singleton_mutations
  mutation '//'
  mutation '/nomatch\A/'
end

Pathname
  .glob(Pathname.new(__dir__).join('regexp', '*.rb'))
  .sort
  .each(&Kernel.public_method(:require))
