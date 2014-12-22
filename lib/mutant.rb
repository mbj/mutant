require 'stringio'
require 'set'
require 'adamantium'
require 'ice_nine'
require 'abstract_type'
require 'equalizer'
require 'digest/sha1'
require 'parser'
require 'parser/current'
require 'unparser'
require 'ice_nine'
require 'diff/lcs'
require 'diff/lcs/hunk'
require 'anima'
require 'concord'
require 'morpher'
require 'parallel'
require 'open3'

# This setting is done to make errors within the parallel
# reporter / execution visible in the main thread.
Thread.abort_on_exception = true

# Library namespace
module Mutant
  # The frozen empty string used within mutant
  EMPTY_STRING = ''.freeze
  # The frozen empty array used within mutant
  EMPTY_ARRAY = [].freeze
  # The frozen empty set used within mutant
  EMPTY_SET = [].to_set.freeze

  SCOPE_OPERATOR = '::'.freeze

  # Test if CI is detected via environment
  #
  # @return [Boolean]
  #
  # @api private
  #
  def self.ci?
    ENV.key?('CI')
  end

  # Lookup constant for location
  #
  # @param [String] location
  #
  # @return [Object]
  #
  # @api private
  #
  def self.constant_lookup(location)
    location.split(SCOPE_OPERATOR).reduce(Object) do |parent, name|
      parent.const_get(name, nil)
    end
  end

  # Perform self zombification
  #
  # @return [self]
  #
  # @api private
  #
  def self.zombify
    Zombifier.run('mutant', :Zombie)
    self
  end

  # Define instance of subclassed superclass as constant
  #
  # @param [Class] superclass
  # @param [Symbol] name
  #
  # @return [self]
  #
  # @api private
  #
  # rubocop:disable MethodLength
  #
  def self.singleton_subclass_instance(name, superclass, &block)
    klass = Class.new(superclass) do
      def inspect
        self.class.name
      end

      define_singleton_method(:name) do
        "#{superclass.name}::#{name}".freeze
      end
    end
    klass.class_eval(&block)
    superclass.const_set(name, klass.new)
    self
  end

end # Mutant

require 'mutant/version'
require 'mutant/simple_inspect'
require 'mutant/env'
require 'mutant/env/bootstrap'
require 'mutant/ast'
require 'mutant/ast/sexp'
require 'mutant/ast/types'
require 'mutant/ast/nodes'
require 'mutant/ast/named_children'
require 'mutant/ast/node_predicates'
require 'mutant/ast/meta'
require 'mutant/actor'
require 'mutant/actor/receiver'
require 'mutant/actor/sender'
require 'mutant/actor/mailbox'
require 'mutant/actor/env'
require 'mutant/parallel'
require 'mutant/parallel/master'
require 'mutant/parallel/worker'
require 'mutant/parallel/source'
require 'mutant/cache'
require 'mutant/delegator'
require 'mutant/warning_filter'
require 'mutant/require_highjack'
require 'mutant/isolation'
require 'mutant/mutator'
require 'mutant/mutation'
require 'mutant/mutator/registry'
require 'mutant/mutator/util'
require 'mutant/mutator/util/array'
require 'mutant/mutator/util/symbol'
require 'mutant/mutator/node'
require 'mutant/mutator/node/generic'
require 'mutant/mutator/node/literal'
require 'mutant/mutator/node/literal/boolean'
require 'mutant/mutator/node/literal/range'
require 'mutant/mutator/node/literal/symbol'
require 'mutant/mutator/node/literal/string'
require 'mutant/mutator/node/literal/fixnum'
require 'mutant/mutator/node/literal/float'
require 'mutant/mutator/node/literal/array'
require 'mutant/mutator/node/literal/hash'
require 'mutant/mutator/node/literal/regex'
require 'mutant/mutator/node/literal/nil'
require 'mutant/mutator/node/argument'
require 'mutant/mutator/node/arguments'
require 'mutant/mutator/node/blockarg'
require 'mutant/mutator/node/begin'
require 'mutant/mutator/node/binary'
require 'mutant/mutator/node/const'
require 'mutant/mutator/node/dstr'
require 'mutant/mutator/node/dsym'
require 'mutant/mutator/node/kwbegin'
require 'mutant/mutator/node/named_value/access'
require 'mutant/mutator/node/named_value/constant_assignment'
require 'mutant/mutator/node/named_value/variable_assignment'
require 'mutant/mutator/node/next'
require 'mutant/mutator/node/break'
require 'mutant/mutator/node/noop'
require 'mutant/mutator/node/or_asgn'
require 'mutant/mutator/node/and_asgn'
require 'mutant/mutator/node/defined'
require 'mutant/mutator/node/op_asgn'
require 'mutant/mutator/node/conditional_loop'
require 'mutant/mutator/node/yield'
require 'mutant/mutator/node/super'
require 'mutant/mutator/node/zsuper'
require 'mutant/mutator/node/restarg'
require 'mutant/mutator/node/send'
require 'mutant/mutator/node/send/binary'
require 'mutant/mutator/node/send/attribute_assignment'
require 'mutant/mutator/node/send/index'
require 'mutant/mutator/node/when'
require 'mutant/mutator/node/define'
require 'mutant/mutator/node/mlhs'
require 'mutant/mutator/node/nthref'
require 'mutant/mutator/node/masgn'
require 'mutant/mutator/node/return'
require 'mutant/mutator/node/block'
require 'mutant/mutator/node/if'
require 'mutant/mutator/node/case'
require 'mutant/mutator/node/splat'
require 'mutant/mutator/node/resbody'
require 'mutant/mutator/node/rescue'
require 'mutant/mutator/node/match_current_line'
require 'mutant/config'
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/scope'
require 'mutant/subject'
require 'mutant/subject/method'
require 'mutant/subject/method/instance'
require 'mutant/subject/method/singleton'
require 'mutant/matcher'
require 'mutant/matcher/config'
require 'mutant/matcher/compiler'
require 'mutant/matcher/chain'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/methods'
require 'mutant/matcher/namespace'
require 'mutant/matcher/scope'
require 'mutant/matcher/filter'
require 'mutant/matcher/null'
require 'mutant/expression'
require 'mutant/expression/method'
require 'mutant/expression/methods'
require 'mutant/expression/namespace'
require 'mutant/test'
require 'mutant/integration'
require 'mutant/selector'
require 'mutant/selector/expression'
require 'mutant/cli'
require 'mutant/color'
require 'mutant/diff'
require 'mutant/runner'
require 'mutant/runner/sink'
require 'mutant/result'
require 'mutant/reporter'
require 'mutant/reporter/null'
require 'mutant/reporter/trace'
require 'mutant/reporter/cli'
require 'mutant/reporter/cli/printer'
require 'mutant/reporter/cli/printer/framed'
require 'mutant/reporter/cli/printer/progressive'
require 'mutant/reporter/cli/printer/report'
require 'mutant/reporter/cli/printer/progress'
require 'mutant/reporter/cli/tput'
require 'mutant/reporter/cli/format'
require 'mutant/trace'
require 'mutant/zombifier'
require 'mutant/zombifier/file'

module Mutant
  # Reopen class to initialize constant to avoid dep circle
  class Config
    CI_DEFAULT_PROCESSOR_COUNT = 2

    DEFAULT = new(
      debug:             false,
      fail_fast:         false,
      integration:       Integration::Null.new,
      matcher_config:    Matcher::Config::DEFAULT,
      includes:          EMPTY_ARRAY,
      requires:          EMPTY_ARRAY,
      isolation:         Mutant::Isolation::Fork,
      reporter:          Reporter::CLI.build($stdout),
      trace:             false,
      zombie:            false,
      jobs:              Mutant.ci? ? CI_DEFAULT_PROCESSOR_COUNT : ::Parallel.processor_count,
      expected_coverage: 100.0
    )
  end # Config
end # Mutant
