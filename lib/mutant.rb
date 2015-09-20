require 'abstract_type'
require 'adamantium'
require 'anima'
require 'concord'
require 'digest/sha1'
require 'diff/lcs'
require 'diff/lcs/hunk'
require 'equalizer'
require 'ice_nine'
require 'morpher'
require 'open3'
require 'optparse'
require 'parallel'
require 'parser'
require 'parser/current'
require 'pathname'
require 'set'
require 'stringio'
require 'unparser'

# This setting is done to make errors within the parallel
# reporter / execution visible in the main thread.
Thread.abort_on_exception = true

# Library namespace
module Mutant
  EMPTY_STRING   = ''.freeze
  EMPTY_ARRAY    = [].freeze
  EMPTY_HASH     = {}.freeze
  SCOPE_OPERATOR = '::'.freeze

  # Test if CI is detected via environment
  #
  # @return [Boolean]
  #
  # @api private
  def self.ci?
    ENV.key?('CI')
  end
end # Mutant

require 'mutant/version'
require 'mutant/env'
require 'mutant/env/bootstrap'
require 'mutant/ast'
require 'mutant/ast/sexp'
require 'mutant/ast/types'
require 'mutant/ast/nodes'
require 'mutant/ast/named_children'
require 'mutant/ast/node_predicates'
require 'mutant/ast/meta'
require 'mutant/ast/meta/send'
require 'mutant/ast/meta/const'
require 'mutant/ast/meta/symbol'
require 'mutant/ast/meta/optarg'
require 'mutant/ast/meta/resbody'
require 'mutant/ast/meta/restarg'
require 'mutant/actor'
require 'mutant/actor/receiver'
require 'mutant/actor/sender'
require 'mutant/actor/mailbox'
require 'mutant/actor/env'
require 'mutant/cache'
require 'mutant/delegator'
require 'mutant/isolation'
require 'mutant/parallel'
require 'mutant/parallel/master'
require 'mutant/parallel/worker'
require 'mutant/parallel/source'
require 'mutant/warning_filter'
require 'mutant/require_highjack'
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
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/scope'
require 'mutant/scope'
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
require 'mutant/matcher/static'
require 'mutant/expression'
require 'mutant/expression/parser'
require 'mutant/expression/method'
require 'mutant/expression/methods'
require 'mutant/expression/namespace'
require 'mutant/test'
require 'mutant/integration'
require 'mutant/selector'
require 'mutant/selector/expression'
require 'mutant/config'
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
require 'mutant/reporter/cli/printer/config'
require 'mutant/reporter/cli/printer/env_result'
require 'mutant/reporter/cli/printer/env_progress'
require 'mutant/reporter/cli/printer/mutation_result'
require 'mutant/reporter/cli/printer/mutation_progress_result'
require 'mutant/reporter/cli/printer/subject_progress'
require 'mutant/reporter/cli/printer/subject_result'
require 'mutant/reporter/cli/printer/status'
require 'mutant/reporter/cli/printer/status_progressive'
require 'mutant/reporter/cli/printer/test_result'
require 'mutant/reporter/cli/tput'
require 'mutant/reporter/cli/format'
require 'mutant/repository'
require 'mutant/zombifier'

module Mutant
  # Reopen class to initialize constant to avoid dep circle
  class Config
    CI_DEFAULT_PROCESSOR_COUNT = 4

    DEFAULT = new(
      debug:             false,
      expected_coverage: Rational(1),
      fail_fast:         false,
      includes:          EMPTY_ARRAY,
      integration:       'null'.freeze,
      jobs:              Mutant.ci? ? CI_DEFAULT_PROCESSOR_COUNT : ::Parallel.processor_count,
      matcher:           Matcher::Config::DEFAULT,
      requires:          EMPTY_ARRAY,
      reporter:          Reporter::CLI.build($stdout),
      zombie:            false
    )
  end # Config

  class Expression
    class Parser
      DEFAULT = Expression::Parser.new([
        Expression::Method,
        Expression::Methods,
        Expression::Namespace::Exact,
        Expression::Namespace::Recursive
      ])
    end # Parser
  end # Expression
end # Mutant
