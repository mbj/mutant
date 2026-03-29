# frozen_string_literal: true

Mutant::Meta::Example.add :op_asgn, :send do
  source '@a.b += 1'

  mutation '@a += 1'
  mutation '@a.b += 0'
  mutation '@a.b += 2'
  mutation '@a.b += nil'
  mutation '@a.b -= 1'
  mutation 'self.b += 1'

  # overflow boundary probe (int8 zone)
  mutation '@a.b += 167'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'a.b += 1'

  mutation 'a.b += 0'
  mutation 'a.b += 2'
  mutation 'a.b += nil'
  mutation 'a.b -= 1'
  mutation 'self.b += 1'

  # overflow boundary probe (int8 zone)
  mutation 'a.b += 167'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'b += 1'

  mutation 'b += 0'
  mutation 'b += 2'
  mutation 'b += nil'
  mutation 'b -= 1'

  # overflow boundary probe (int8 zone)
  mutation 'b += 167'
end

# Subtraction operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a -= 1'

  mutation 'a -= 0'
  mutation 'a -= 2'
  mutation 'a -= nil'
  mutation 'a += 1'

  # overflow boundary probe (int8 zone)
  mutation 'a -= 167'
end

# Multiplication operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a *= 2'

  mutation 'a *= nil'
  mutation 'a *= 0'
  mutation 'a *= 1'
  mutation 'a *= 3'
  mutation 'a /= 2'

  # overflow boundary probe (int8 zone)
  mutation 'a *= 167'
end

# Division operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a /= 2'

  mutation 'a /= nil'
  mutation 'a /= 0'
  mutation 'a /= 1'
  mutation 'a /= 3'
  mutation 'a *= 2'

  # overflow boundary probe (int8 zone)
  mutation 'a /= 167'
end

# Modulo operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a %= 2'

  mutation 'a %= nil'
  mutation 'a %= 0'
  mutation 'a %= 1'
  mutation 'a %= 3'
  mutation 'a /= 2'

  # overflow boundary probe (int8 zone)
  mutation 'a %= 167'
end

# Exponentiation operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a **= 2'

  mutation 'a **= nil'
  mutation 'a **= 0'
  mutation 'a **= 1'
  mutation 'a **= 3'
  mutation 'a *= 2'

  # overflow boundary probe (int8 zone)
  mutation 'a **= 167'
end

# Bitwise AND operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a &= b'

  mutation 'a &= nil'
  mutation 'a |= b'
end

# Bitwise OR operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a |= b'

  mutation 'a |= nil'
  mutation 'a &= b'
  mutation 'a ^= b'
end

# Bitwise XOR operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a ^= b'

  mutation 'a ^= nil'
  mutation 'a &= b'
  mutation 'a |= b'
end

# Left shift operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a <<= 1'

  mutation 'a <<= nil'
  mutation 'a <<= 0'
  mutation 'a <<= 2'
  mutation 'a >>= 1'

  # overflow boundary probe (int8 zone)
  mutation 'a <<= 167'
end

# Right shift operator swap
Mutant::Meta::Example.add :op_asgn do
  source 'a >>= 1'

  mutation 'a >>= nil'
  mutation 'a >>= 0'
  mutation 'a >>= 2'
  mutation 'a <<= 1'

  # overflow boundary probe (int8 zone)
  mutation 'a >>= 167'
end
