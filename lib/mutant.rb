# frozen_string_literal: true

# Library namespace
#
# @api private
# rubocop:disable Metrics/ModuleLength
module Mutant
  # Boot timing infrastructure
  get_timestamp = lambda do
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  library_timestamp = get_timestamp.call
  boot_events       = []

  record = lambda do |name, &block|
    start = get_timestamp.call

    block.call.tap do
      boot_events << [name, start, get_timestamp.call]
    end
  end

  record.call(:require_dependencies) do
    %w[
      diff/lcs
      diff/lcs/hunk
      digest/sha1
      etc
      irb
      json
      open3
      optparse
      parser
      parser/current
      pathname
      regexp_parser
      securerandom
      set
      singleton
      sorbet-runtime
      stringio
      unparser
      yaml
    ].each { |name| require(name) }
  end

  # This setting is done to make errors within the parallel
  # reporter / execution visible in the main thread.
  Thread.abort_on_exception = true

  AbstractType = Unparser::AbstractType
  Adamantium   = Unparser::Adamantium
  Anima        = Unparser::Anima
  Concord      = Unparser::Concord
  Either       = Unparser::Either
  Equalizer    = Unparser::Equalizer

  EMPTY_STRING   = ''
  EMPTY_ARRAY    = [].freeze
  EMPTY_HASH     = {}.freeze
  SCOPE_OPERATOR = '::'

  env_key = /[a-zA-Z_\d]+/

  ENV_VARIABLE_KEY_VALUE_REGEXP = /\A(?<key>#{env_key}+)=(?<value>.*)\z/.freeze
  ENV_VARIABLE_KEY_REGEXP       = /\A#{env_key}\z/.freeze

  # rubocop:disable Metrics/BlockLength
  record.call(:require_mutant_lib) do
    require 'mutant/procto'
    require 'mutant/transform'
    require 'mutant/variable'
    require 'mutant/bootstrap'
    require 'mutant/version'
    require 'mutant/env'
    require 'mutant/pipe'
    require 'mutant/util'
    require 'mutant/registry'
    require 'mutant/ast'
    require 'mutant/ast/sexp'
    require 'mutant/ast/types'
    require 'mutant/ast/nodes'
    require 'mutant/ast/named_children'
    require 'mutant/ast/node_predicates'
    require 'mutant/ast/find_metaclass_containing'
    require 'mutant/ast/meta'
    require 'mutant/ast/meta/send'
    require 'mutant/ast/meta/const'
    require 'mutant/ast/meta/symbol'
    require 'mutant/ast/meta/optarg'
    require 'mutant/ast/meta/resbody'
    require 'mutant/ast/pattern'
    require 'mutant/ast/pattern/lexer'
    require 'mutant/ast/pattern/parser'
    require 'mutant/ast/pattern/source'
    require 'mutant/ast/pattern/token'
    require 'mutant/ast/structure'
    require 'mutant/parser'
    require 'mutant/isolation'
    require 'mutant/isolation/exception'
    require 'mutant/isolation/fork'
    require 'mutant/isolation/none'
    require 'mutant/parallel'
    require 'mutant/parallel/driver'
    require 'mutant/parallel/source'
    require 'mutant/parallel/worker'
    require 'mutant/require_highjack'
    require 'mutant/mutation'
    require 'mutant/mutation/config'
    require 'mutant/mutator'
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
    require 'mutant/mutator/node/dynamic_literal'
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
    require 'mutant/mutator/node/when'
    require 'mutant/mutator/node/class'
    require 'mutant/mutator/node/sclass'
    require 'mutant/mutator/node/define'
    require 'mutant/mutator/node/mlhs'
    require 'mutant/mutator/node/nthref'
    require 'mutant/mutator/node/masgn'
    require 'mutant/mutator/node/module'
    require 'mutant/mutator/node/return'
    require 'mutant/mutator/node/block'
    require 'mutant/mutator/node/block_pass'
    require 'mutant/mutator/node/if'
    require 'mutant/mutator/node/case'
    require 'mutant/mutator/node/splat'
    require 'mutant/mutator/node/regopt'
    require 'mutant/mutator/node/resbody'
    require 'mutant/mutator/node/rescue'
    require 'mutant/mutator/node/match_current_line'
    require 'mutant/mutator/node/index'
    require 'mutant/mutator/node/procarg_zero'
    require 'mutant/mutator/node/kwargs'
    require 'mutant/mutator/node/numblock'
    require 'mutant/mutator/regexp'
    require 'mutant/loader'
    require 'mutant/context'
    require 'mutant/scope'
    require 'mutant/subject'
    require 'mutant/subject/config'
    require 'mutant/subject/method'
    require 'mutant/subject/method/instance'
    require 'mutant/subject/method/singleton'
    require 'mutant/subject/method/metaclass'
    require 'mutant/matcher'
    require 'mutant/matcher/chain'
    require 'mutant/matcher/config'
    require 'mutant/matcher/descendants'
    require 'mutant/matcher/filter'
    require 'mutant/matcher/method'
    require 'mutant/matcher/method/instance'
    require 'mutant/matcher/method/metaclass'
    require 'mutant/matcher/method/singleton'
    require 'mutant/matcher/methods'
    require 'mutant/matcher/namespace'
    require 'mutant/matcher/null'
    require 'mutant/matcher/scope'
    require 'mutant/matcher/static'
    require 'mutant/expression'
    require 'mutant/expression/descendants'
    require 'mutant/expression/method'
    require 'mutant/expression/methods'
    require 'mutant/expression/namespace'
    require 'mutant/expression/parser'
    require 'mutant/test'
    require 'mutant/timer'
    require 'mutant/integration'
    require 'mutant/integration/null'
    require 'mutant/selector'
    require 'mutant/selector/expression'
    require 'mutant/selector/null'
    require 'mutant/world'
    require 'mutant/hooks'
    require 'mutant/config'
    require 'mutant/config/coverage_criteria'
    require 'mutant/cli'
    require 'mutant/cli/command'
    require 'mutant/cli/command/subscription'
    require 'mutant/cli/command/environment'
    require 'mutant/cli/command/environment/irb'
    require 'mutant/cli/command/environment/run'
    require 'mutant/cli/command/environment/show'
    require 'mutant/cli/command/environment/subject'
    require 'mutant/cli/command/environment/test'
    require 'mutant/cli/command/util'
    require 'mutant/cli/command/root'
    require 'mutant/runner'
    require 'mutant/runner/sink'
    require 'mutant/result'
    require 'mutant/reporter'
    require 'mutant/reporter/null'
    require 'mutant/reporter/sequence'
    require 'mutant/reporter/cli'
    require 'mutant/reporter/cli/printer'
    require 'mutant/reporter/cli/printer/config'
    require 'mutant/reporter/cli/printer/coverage_result'
    require 'mutant/reporter/cli/printer/env'
    require 'mutant/reporter/cli/printer/env_progress'
    require 'mutant/reporter/cli/printer/env_result'
    require 'mutant/reporter/cli/printer/isolation_result'
    require 'mutant/reporter/cli/printer/mutation'
    require 'mutant/reporter/cli/printer/mutation_result'
    require 'mutant/reporter/cli/printer/status_progressive'
    require 'mutant/reporter/cli/printer/subject_result'
    require 'mutant/reporter/cli/format'
    require 'mutant/repository'
    require 'mutant/repository/diff'
    require 'mutant/repository/diff/ranges'
    require 'mutant/repository/file_revision'
    require 'mutant/zombifier'
    require 'mutant/range'
    require 'mutant/license'
    require 'mutant/license/subscription'
    require 'mutant/license/subscription/opensource'
    require 'mutant/license/subscription/commercial'
    require 'mutant/segment'
    require 'mutant/segment/recorder'
  end
  # rubocop:enable Metrics/BlockLength

  gen_id = SecureRandom.method(:uuid)

  # Transform boot events into segments
  if instance_variable_defined?(:@executable_timestamp)
    recording_start = @executable_timestamp

    executable_segment =
      Segment.new(
        id:              gen_id.call,
        name:            :executable,
        parent_id:       nil,
        timestamp_end:   nil,
        timestamp_start: @executable_timestamp
      )

    remove_instance_variable(:@executable_timestamp)
  else
    recording_start = library_timestamp
  end

  library_segment = Segment.new(
    id:              gen_id.call,
    name:            :library,
    parent_id:       executable_segment&.id,
    timestamp_end:   nil,
    timestamp_start: library_timestamp
  )

  boot_segments = boot_events.map do |name, timestamp_start, timestamp_end|
    Segment.new(
      id:              gen_id.call,
      name:            name,
      parent_id:       library_segment.id,
      timestamp_end:   timestamp_end,
      timestamp_start: timestamp_start
    )
  end

  timer = Timer.new(Process)

  recorder = Segment::Recorder.new(
    gen_id:          gen_id,
    root_id:         (executable_segment || library_segment).id,
    parent_id:       library_segment.id,
    recording_start: recording_start,
    segments:        [*executable_segment, library_segment, *boot_segments],
    timer:           timer
  )

  WORLD = World.new(
    condition_variable:    ConditionVariable,
    environment_variables: ENV,
    gem:                   Gem,
    gem_method:            method(:gem),
    io:                    IO,
    json:                  JSON,
    kernel:                Kernel,
    load_path:             $LOAD_PATH,
    marshal:               Marshal,
    mutex:                 Mutex,
    object_space:          ObjectSpace,
    open3:                 Open3,
    parser:                Parser.new,
    pathname:              Pathname,
    process:               Process,
    random:                Random,
    recorder:              recorder,
    stderr:                $stderr,
    stdout:                $stdout,
    thread:                Thread,
    timer:                 timer
  )

  # Reopen class to initialize constant to avoid dep circle
  class Config
    DEFAULT = new(
      coverage_criteria:     Config::CoverageCriteria::DEFAULT,
      expression_parser:     Expression::Parser.new([
        Expression::Descendants,
        Expression::Method,
        Expression::Methods,
        Expression::Namespace::Exact,
        Expression::Namespace::Recursive
      ]),
      environment_variables: EMPTY_HASH,
      fail_fast:             false,
      hooks:                 EMPTY_ARRAY,
      includes:              EMPTY_ARRAY,
      integration:           nil,
      isolation:             Mutant::Isolation::Fork.new(WORLD),
      jobs:                  nil,
      matcher:               Matcher::Config::DEFAULT,
      mutation:              Mutation::Config::DEFAULT,
      reporter:              Reporter::CLI.build(WORLD.stdout),
      requires:              EMPTY_ARRAY
    )
  end # Config

  # Traverse values against action
  #
  # Specialized to Either. Its *always* traverse.
  def self.traverse(action, values)
    Either::Right.new(
      values.map do |value|
        action.call(value).from_right do |error|
          return Either::Left.new(error)
        end
      end
    )
  end
end # Mutant
# rubocop:enable Metrics/ModuleLength
