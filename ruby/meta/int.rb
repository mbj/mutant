# frozen_string_literal: true

Mutant::Meta::Example.add :int do
  source '10'

  singleton_mutations

  # edge cases
  mutation '0'
  mutation '1'

  # scalar boundary
  mutation '9'
  mutation '11'

  # overflow boundary probe (int8 zone)
  mutation '167'
end

Mutant::Meta::Example.add :int do
  source '-200'

  singleton_mutations

  # edge cases
  mutation '0'
  mutation '1'

  # scalar boundary
  mutation '-201'
  mutation '-199'

  # overflow boundary probe (uint8 zone, based on abs value)
  mutation '467'
end

Mutant::Meta::Example.add :int do
  source '200'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '199'
  mutation '201'

  # overflow boundary probe (uint8 zone)
  mutation '467'
end

Mutant::Meta::Example.add :int do
  source '500'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '499'
  mutation '501'

  # overflow boundary probe (int16 zone)
  mutation '55_487'
end

Mutant::Meta::Example.add :int do
  source '40_000'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '39_999'
  mutation '40_001'

  # overflow boundary probe (uint16 zone)
  mutation '108_503'
end

Mutant::Meta::Example.add :int do
  source '100_000'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '99_999'
  mutation '100_001'

  # overflow boundary probe (int32 zone)
  mutation '2_667_278_543'
end

Mutant::Meta::Example.add :int do
  source '3_000_000_000'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '2_999_999_999'
  mutation '3_000_000_001'

  # overflow boundary probe (uint32 zone)
  mutation '7_980_081_959'
end

Mutant::Meta::Example.add :int do
  source '5_000_000_000'

  singleton_mutations

  mutation '0'
  mutation '1'
  mutation '4_999_999_999'
  mutation '5_000_000_001'

  # overflow boundary probe (int64 zone)
  mutation '15_508_464_536_481_899_903'
end
