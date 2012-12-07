require 'backports'
require 'adamantium'
require 'ice_nine'
require 'abstract_type'
require 'descendants_tracker'
require 'securerandom'
require 'equalizer'
require 'digest/sha1'
require 'to_source'
require 'inflector'
require 'ice_nine'
require 'ice_nine/core_ext/object'
require 'diff/lcs'
require 'diff/lcs/hunk'
require 'rspec'

# Library namespace
module Mutant

  # Define instance of subclassed superclass as constant
  #
  # @param [Class] superclass
  # @param [Symbol] name
  #
  # @return [self]
  #
  # @api private
  #
  def self.define_singleton_subclass(name, superclass, &block)
    klass = Class.new(superclass) do

      def inspect; self.class.name; end

      define_singleton_method(:name) do
        "#{superclass.name}::#{name}".freeze
      end

    end
    klass.class_eval(&block)
    superclass.const_set(name, klass.new)
    self
  end

end

require 'mutant/support/method_object'
require 'mutant/helper'
require 'mutant/random'
require 'mutant/mutator'
require 'mutant/mutation'
require 'mutant/mutation/filter'
require 'mutant/mutation/filter/code'
require 'mutant/mutation/filter/whitelist'
require 'mutant/mutator/registry'
require 'mutant/mutator/util'
require 'mutant/mutator/node'
require 'mutant/mutator/node/literal'
require 'mutant/mutator/node/literal/boolean'
require 'mutant/mutator/node/literal/range'
require 'mutant/mutator/node/literal/symbol'
require 'mutant/mutator/node/literal/string'
require 'mutant/mutator/node/literal/fixnum'
require 'mutant/mutator/node/literal/float'
require 'mutant/mutator/node/literal/array'
require 'mutant/mutator/node/literal/empty_array'
require 'mutant/mutator/node/literal/hash'
require 'mutant/mutator/node/literal/regex'
require 'mutant/mutator/node/literal/nil'
require 'mutant/mutator/node/block'
require 'mutant/mutator/node/noop'
require 'mutant/mutator/node/send'
require 'mutant/mutator/node/arguments'
require 'mutant/mutator/node/define'
require 'mutant/mutator/node/return'
require 'mutant/mutator/node/if_statement'
require 'mutant/mutator/node/receiver_case'
require 'mutant/loader' 
require 'mutant/context'
require 'mutant/context/scope'
require 'mutant/subject'
require 'mutant/matcher'
require 'mutant/matcher/chain'
require 'mutant/matcher/object_space'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
require 'mutant/matcher/scope_methods'
require 'mutant/killer'
require 'mutant/killer/static'
require 'mutant/killer/rspec'
require 'mutant/killer/forking'
require 'mutant/strategy'
require 'mutant/strategy/rspec'
require 'mutant/strategy/rspec/example_lookup'
require 'mutant/runner'
require 'mutant/cli'
require 'mutant/color'
require 'mutant/differ'
require 'mutant/reporter'
require 'mutant/reporter/stats'
require 'mutant/reporter/null'
require 'mutant/reporter/cli'
