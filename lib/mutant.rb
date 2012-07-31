# For Veritas::Immutable. will be extracted soon
require 'veritas'
# For Virtus::DescendantsTracker. will be extracted soon
require 'virtus'

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
require 'mutant/mutator/literal'
require 'mutant/mutator/literal/boolean'
require 'mutant/mutator/literal/range'
require 'mutant/mutator/literal/symbol'
require 'mutant/mutator/literal/string'
require 'mutant/mutator/literal/fixnum'
require 'mutant/mutator/literal/float'
require 'mutant/mutator/literal/array'
require 'mutant/mutator/literal/empty_array'
require 'mutant/mutator/literal/hash'
require 'mutant/mutator/literal/regex'
#require 'mutant/mutator/literal/dynamic'
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
