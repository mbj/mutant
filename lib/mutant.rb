# encoding: utf-8

require 'stringio'
require 'set'
require 'adamantium'
require 'ice_nine'
require 'abstract_type'
require 'equalizer'
require 'digest/sha1'
require 'inflecto'
require 'parser'
require 'parser/current'
require 'parser_extensions'
require 'unparser'
require 'ice_nine'
require 'diff/lcs'
require 'diff/lcs/hunk'
require 'anima'
require 'concord'
require 'morpher'

# Library namespace
module Mutant
  # The frozen empty string used within mutant
  EMPTY_STRING = ''.freeze
  # The frozen empty array used within mutant
  EMPTY_ARRAY = [].freeze

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

  IsolationError = Class.new(RuntimeError)

  # Call block in isolation
  #
  # This isolation implements the fork strategy.
  # Future strategies will probably use a process pool that can
  # handle multiple mutation kills, in-isolation at once.
  #
  # @return [Object]
  #
  # @api private
  #
  def self.isolate(&block)
    reader, writer = IO.pipe

    pid = fork do
      reader.close
      writer.write(Marshal.dump(block.call))
    end

    writer.close

    begin
      data = Marshal.load(reader.read)
    rescue ArgumentError
      raise IsolationError, 'Childprocess wrote unmarshallable data'
    end

    status = Process.waitpid2(pid).last

    unless status.exitstatus.zero?
      raise IsolationError, "Childprocess exited with nonzero exit status: #{status.exitstatus}"
    end

    data
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
require 'mutant/cache'
require 'mutant/node_helpers'
require 'mutant/warning_filter'
require 'mutant/warning_expectation'
require 'mutant/constants'
require 'mutant/walker'
require 'mutant/require_highjack'
require 'mutant/mutator'
require 'mutant/mutation'
require 'mutant/mutation/evil'
require 'mutant/mutation/neutral'
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
require 'mutant/mutator/node/loop_control'
require 'mutant/mutator/node/noop'
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
require 'mutant/matcher/chain'
require 'mutant/matcher/method'
require 'mutant/matcher/method/finder'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/methods'
require 'mutant/matcher/namespace'
require 'mutant/matcher/scope'
require 'mutant/matcher/filter'
require 'mutant/matcher/null'
require 'mutant/killer'
require 'mutant/test'
require 'mutant/strategy'
require 'mutant/runner'
require 'mutant/runner/config'
require 'mutant/runner/subject'
require 'mutant/runner/mutation'
require 'mutant/runner/killer'
require 'mutant/cli'
require 'mutant/cli/classifier'
require 'mutant/cli/classifier/namespace'
require 'mutant/cli/classifier/method'
require 'mutant/color'
require 'mutant/diff'
require 'mutant/reporter'
require 'mutant/reporter/null'
require 'mutant/reporter/cli'
require 'mutant/reporter/cli/printer'
require 'mutant/reporter/cli/printer/config'
require 'mutant/reporter/cli/printer/subject'
require 'mutant/reporter/cli/printer/mutation'
require 'mutant/reporter/cli/printer/progress'
require 'mutant/zombifier'
require 'mutant/zombifier/file'
