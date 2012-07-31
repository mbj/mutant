# For Veritas::Immutable. will be extracted soon
require 'veritas'

require 'securerandom'

# Library namespace
module Mutant
  # Return random string
  #
  # @return [String]
  #
  # @api private
  #
  def self.random_hex_string
    SecureRandom.hex(10)
  end

  # Return random fixnum
  #
  # @return [Fixnum]
  #
  # @api private
  #
  def self.random_fixnum
    Random.rand(1000)
  end

  # Return random float
  #
  # @return [Float]
  #
  # @api private
  #
  def self.random_float
    Random.rand
  end
end

require 'mutant/support/abstract'
require 'mutant/mutator'

require 'mutant/mutator/abstract_range'
require 'mutant/mutator/range'
require 'mutant/mutator/range_exclude'

require 'mutant/mutator/boolean'
require 'mutant/mutator/true_literal'
require 'mutant/mutator/false_literal'

require 'mutant/mutator/symbol_literal'
require 'mutant/mutator/string_literal'
require 'mutant/mutator/fixnum_literal'
require 'mutant/mutator/float_literal'
require 'mutant/mutator/array_literal'
require 'mutant/mutator/empty_array'
require 'mutant/mutator/hash_literal'
require 'mutant/mutator/regex_literal'
require 'mutant/mutator/dynamic_string'
require 'mutant/mutator/block'
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/constant'
require 'mutant/mutatee'
require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
