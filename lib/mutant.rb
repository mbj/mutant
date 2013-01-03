require 'backports'
require 'set'
require 'adamantium'
require 'ice_nine'
require 'abstract_type'
require 'descendants_tracker'
require 'securerandom'
require 'equalizer'
require 'digest/sha1'
require 'inflector'
require 'to_source'
require 'ice_nine'
require 'diff/lcs'
require 'diff/lcs/hunk'
require 'rspec'

# Patch ice none to freeze nodes correctly
class IceNine::Freezer
  # Rubinius namsepace
  class Rubinius 
    # AST namespace
    class AST < IceNine::Freezer::Object
      # Node configuration
      class Node < IceNine::Freezer::Object
      end
    end
  end
end

# Library namespace
module Mutant

  # The list of ruby kewords from http://ruby-doc.org/docs/keywords/1.9/
  KEYWORDS = %w(
    BEGIN END __ENCODING__ __END__ __FILE__
    __LINE__ alias and begin break case class
    def define do else elsif end ensure false
    for if in module next nil not or redo
    rescue retry return self super then true
    undef unless until when while yield
  ).map(&:to_sym).to_set.freeze

  BINARY_METHOD_OPERATOR_EXPANSIONS = {
    :<=>  => :spaceship_operator,
    :===  => :case_equality_operator,
    :[]=  => :element_writer,
    :[]   => :element_reader,
    :<=   => :less_than_or_equal_to_operator,
    :>=   => :greater_than_or_equal_to_operator,
    :==   => :equality_operator,
    :'!~' => :nomatch_operator,
    :'!=' => :inequality_operator,
    :=~   => :match_operator,
    :<<   => :left_shift_operator,
    :>>   => :right_shift_operator,
    :**   => :exponentation_operator,
    :*    => :multiplication_operator,
    :%    => :modulo_operator,
    :/    => :division_operator,
    :|    => :bitwise_or_operator,
    :^    => :bitwise_xor_operator,
    :&    => :bitwise_and_operator,
    :<    => :less_than_operator,
    :>    => :greater_than_operator,
    :+    => :addition_operator,
    :-    => :substraction_operator
  }.freeze

  UNARY_METHOD_OPERATOR_EXPANSIONS = {
    :~@   => :unary_match_operator,
    :+@   => :unary_addition_operator,
    :-@   => :unary_substraction_operator,
    :'!'  => :negation_operator
  }.freeze

  BINARY_METHOD_OPERATORS = BINARY_METHOD_OPERATOR_EXPANSIONS.keys.to_set.freeze

  OPERATOR_EXPANSIONS = BINARY_METHOD_OPERATOR_EXPANSIONS.merge(UNARY_METHOD_OPERATOR_EXPANSIONS).freeze

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
require 'mutant/mutator/util/array'
require 'mutant/mutator/util/symbol'
require 'mutant/mutator/node'
require 'mutant/mutator/node/noop'
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
require 'mutant/mutator/node/while'
require 'mutant/mutator/node/super'
require 'mutant/mutator/node/send'
require 'mutant/mutator/node/assignment'
require 'mutant/mutator/node/define'
require 'mutant/mutator/node/formal_arguments_19'
require 'mutant/mutator/node/formal_arguments_19/default_mutations'
require 'mutant/mutator/node/formal_arguments_19/require_defaults'
require 'mutant/mutator/node/formal_arguments_19/pattern_argument_expansion'
require 'mutant/mutator/node/actual_arguments'
require 'mutant/mutator/node/pattern_arguments'
require 'mutant/mutator/node/pattern_variable'
require 'mutant/mutator/node/default_arguments'
require 'mutant/mutator/node/return'
require 'mutant/mutator/node/iter_19'
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
require 'mutant/matcher/scope_methods'
require 'mutant/matcher/method/classifier'
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
