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
require 'regexp_parser'
require 'set'
require 'stringio'
require 'unparser'

# This setting is done to make errors within the parallel
# reporter / execution visible in the main thread.
Thread.abort_on_exception = true

# Library namespace
#
# @api private
module Mutant
  EMPTY_STRING   = ''.freeze
  EMPTY_ARRAY    = [].freeze
  EMPTY_HASH     = {}.freeze
  SCOPE_OPERATOR = '::'.freeze

  # Test if CI is detected via environment
  #
  # @return [Boolean]
  def self.ci?
    ENV.key?('CI')
  end
end # Mutant

require 'mutant/version'
require 'mutant/env'
require 'mutant/env/bootstrap'
require 'mutant/util'
require 'mutant/registry'
require 'mutant/ast'
require 'mutant/ast/sexp'
require 'mutant/ast/types'
require 'mutant/ast/nodes'
require 'mutant/ast/named_children'
require 'mutant/ast/node_predicates'
require 'mutant/ast/regexp'
require 'mutant/ast/regexp/transformer'
require 'mutant/ast/regexp/transformer/direct'
require 'mutant/ast/regexp/transformer/text'
require 'mutant/ast/regexp/transformer/recursive'
require 'mutant/ast/regexp/transformer/quantifier'
require 'mutant/ast/regexp/transformer/options_group'
require 'mutant/ast/regexp/transformer/character_set'
require 'mutant/ast/regexp/transformer/root'
require 'mutant/ast/regexp/transformer/alternative'
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
require 'mutant/parser'
require 'mutant/isolation'
require 'mutant/isolation/none'
require 'mutant/isolation/fork'
require 'mutant/parallel'
require 'mutant/parallel/master'
require 'mutant/parallel/worker'
require 'mutant/parallel/source'
require 'mutant/warning_filter'
require 'mutant/require_highjack'
require 'mutant/mutation'
require 'mutant/mutator'
require 'mutant/mutator/util'
require 'mutant/mutator/util/array'
require 'mutant/mutator/util/symbol'
require 'mutant/mutator/node'
require 'mutant/mutator/node/generic'
require 'mutant/mutator/node/regexp'
require 'mutant/mutator/node/regexp/alternation_meta'
require 'mutant/mutator/node/regexp/capture_group'
require 'mutant/mutator/node/regexp/character_type'
require 'mutant/mutator/node/regexp/end_of_line_anchor'
require 'mutant/mutator/node/regexp/end_of_string_or_before_end_of_line_anchor'
require 'mutant/mutator/node/regexp/greedy_zero_or_more'
require 'mutant/mutator/node/literal'
require 'mutant/mutator/node/literal/boolean'
require 'mutant/mutator/node/literal/range'
require 'mutant/mutator/node/literal/symbol'
require 'mutant/mutator/node/literal/string'
require 'mutant/mutator/node/literal/integer'
require 'mutant/mutator/node/literal/float'
require 'mutant/mutator/node/literal/array'
require 'mutant/mutator/node/literal/hash'
require 'mutant/mutator/node/literal/regex'
require 'mutant/mutator/node/literal/nil'
require 'mutant/mutator/node/argument'
require 'mutant/mutator/node/arguments'
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
require 'mutant/mutator/node/send'
require 'mutant/mutator/node/send/binary'
require 'mutant/mutator/node/send/conditional'
require 'mutant/mutator/node/send/attribute_assignment'
require 'mutant/mutator/node/send/index'
require 'mutant/mutator/node/when'
require 'mutant/mutator/node/class'
require 'mutant/mutator/node/define'
require 'mutant/mutator/node/mlhs'
require 'mutant/mutator/node/nthref'
require 'mutant/mutator/node/masgn'
require 'mutant/mutator/node/return'
require 'mutant/mutator/node/block'
require 'mutant/mutator/node/if'
require 'mutant/mutator/node/case'
require 'mutant/mutator/node/splat'
require 'mutant/mutator/node/regopt'
require 'mutant/mutator/node/resbody'
require 'mutant/mutator/node/rescue'
require 'mutant/mutator/node/match_current_line'
require 'mutant/loader'
require 'mutant/context'
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
require 'mutant/reporter/sequence'
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
    DEFAULT = new(
      expression_parser: Expression::Parser.new([
        Expression::Method,
        Expression::Methods,
        Expression::Namespace::Exact,
        Expression::Namespace::Recursive
      ]),
      fail_fast:         false,
      includes:          EMPTY_ARRAY,
      integration:       Integration::Null,
      isolation:         Mutant::Isolation::Fork.new(
        devnull: ->(&block) { File.open(File::NULL, File::WRONLY, &block) },
        stdout:  $stdout,
        stderr:  $stderr,
        io:      IO,
        marshal: Marshal,
        process: Process
      ),
      jobs:              ::Parallel.processor_count,
      kernel:            Kernel,
      load_path:         $LOAD_PATH,
      matcher:           Matcher::Config::DEFAULT,
      open3:             Open3,
      pathname:          Pathname,
      requires:          EMPTY_ARRAY,
      reporter:          Reporter::CLI.build($stdout),
      zombie:            false
    )
  end # Config
end # Mutant
