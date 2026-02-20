# frozen_string_literal: true

require 'mutant'
require 'mutant/meta'
require 'rspec/its'
require 'timeout'
require 'tempfile'
require 'tmpdir'

module MutantSpec
  AbstractType = Mutant::AbstractType
  Adamantium   = Mutant::Adamantium
  Anima        = Mutant::Anima
  Concord      = Mutant::Concord
  Either       = Mutant::Either
  Equalizer    = Mutant::Equalizer
end

require './spec/shared/framework_integration_behavior'
require './spec/shared/method_matcher_behavior'
require './spec/shared/config_merge_behavior'
require './spec/support/corpus'
require './spec/support/file_system'
require './spec/support/ruby_vm'
require './spec/support/shared_context'
require './spec/support/xspec'

$LOAD_PATH << File.expand_path('../test_app/lib', __dir__)

require 'test_app'

module Fixtures
  test_config = Mutant::Config::DEFAULT
    .with(
      integration: Mutant::Integration::Config::DEFAULT.with(name: 'null'),
      jobs:        1,
      mutation:    Mutant::Mutation::Config::DEFAULT,
      reporter:    Mutant::Reporter::Null.new
    )

  id = 0

  gen_id = -> { (id += 1).to_s }

  root_segment = Mutant::Segment.new(
    id:              0,
    name:            :spec,
    parent_id:       nil,
    timestamp_end:   nil,
    timestamp_start: 0
  )

  recorder = Mutant::Segment::Recorder.new(
    gen_id:,
    root_id:         root_segment.id,
    parent_id:       root_segment.id,
    recording_start: 0,
    segments:        [root_segment],
    timer:           Mutant::WORLD.timer
  )

  TEST_ENV = Mutant::Bootstrap
    .call(Mutant::Env.empty(Mutant::WORLD.with(recorder:), test_config))
    .from_right
end # Fixtures

module PreludeHelper
  def right(value)
    Mutant::Either::Right.new(value)
  end

  def left(value)
    Mutant::Either::Left.new(value)
  end
end

module ParserHelper
  def generate(node)
    Unparser.unparse(node)
  end

  def parse(string)
    Unparser.parse(string)
  end

  def parse_expression(string)
    Mutant::Config::DEFAULT.expression_parser.call(string).from_right
  end
end # ParserHelper

module XSpecHelper
  def verify_events(&)
    expectations = raw_expectations
      .map { |attributes| XSpec::MessageExpectation.parse(**attributes) }

    XSpec::ExpectationVerifier.verify(self, expectations, &)
  end

  def undefined
    double('undefined')
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def fake_world
    Mutant::World.new(
      condition_variable:    class_double(ConditionVariable),
      environment_variables: instance_double(Hash),
      gem:                   class_double(Gem),
      gem_method:            instance_double(Proc),
      io:                    class_double(IO),
      json:                  class_double(JSON),
      kernel:                class_double(Kernel),
      load_path:             instance_double(Array),
      marshal:               class_double(Marshal),
      mutex:                 class_double(Mutex),
      object_space:          class_double(ObjectSpace),
      open3:                 class_double(Open3),
      pathname:              class_double(Pathname),
      process:               class_double(Process),
      random:                class_double(Random),
      recorder:              instance_double(Mutant::Segment::Recorder),
      stderr:                instance_double(IO, :stderr),
      stdout:                instance_double(IO, :stdout),
      tempfile:              class_double(Tempfile),
      thread:                class_double(Thread),
      time:                  class_double(Time),
      timer:                 instance_double(Mutant::Timer)
    )
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end # XSpecHelper

RSpec.configuration.around(file_path: %r{spec/unit}) do |example|
  Timeout.timeout(3, &example)
end

RSpec.shared_examples_for 'a command method' do
  it 'returns self' do
    is_expected.to equal(object)
  end
end

RSpec.shared_examples_for 'an idempotent method' do
  it 'is idempotent' do
    first = subject
    fail 'RSpec not configured for threadsafety' unless RSpec.configuration.threadsafe?
    mutex    = __memoized.instance_variable_get(:@mutex)
    memoized = __memoized.instance_variable_get(:@memoized)

    mutex.synchronize { memoized.delete(:subject) }
    is_expected.to equal(first)
  end
end

RSpec.configure do |config|
  config.extend(SharedContext)
  config.include(ParserHelper)
  config.include(Mutant::AST::Sexp)
  config.include(XSpecHelper)
  config.include(PreludeHelper)
end
