# For Veritas::Immutable. will be extracted soon
require 'veritas'

require 'securerandom'
require 'to_source'
require 'ice_nine'

# Library namespace
module Mutant

  # Return deep clone of object
  #
  # @param [Object] object
  #
  # @return [Object] object
  #
  # @api private
  #
  def self.deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end
  
  # Check for ruby-1.8 mode
  #
  # @return [true]
  #   returns true if running under 1.8 mode
  #
  # @return [false]
  #   returns false otherwise
  #
  # @api private
  #
  def self.on_18?
    RUBY_VERSION == '1.8.7'
  end
end

require 'mutant/support/abstract'
require 'mutant/random'
require 'mutant/mutator'
require 'mutant/mutator/registry'
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
require 'mutant/mutator/noop'
require 'mutant/mutator/call'
require 'mutant/mutator/call'
require 'mutant/mutator/if_statement'
require 'mutant/loader' 
require 'mutant/context'
require 'mutant/context/constant'
require 'mutant/mutatee'
require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
