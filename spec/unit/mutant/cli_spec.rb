# frozen_string_literal: true

RSpec.describe Mutant::CLI do
  describe '.parse' do
    let(:events)                 { []                                        }
    let(:expected_print_profile) { false                                     }
    let(:expected_zombie)        { false                                     }
    let(:kernel)                 { class_double(Kernel)                      }
    let(:stderr)                 { instance_double(IO, :stderr, tty?: false) }
    let(:stdout)                 { instance_double(IO, :stdout, tty?: false) }
    let(:timer)                  { instance_double(Mutant::Timer)            }

    let(:world) do
      instance_double(
        Mutant::World,
        kernel:,
        recorder: instance_double(Mutant::Segment::Recorder),
        stderr:,
        stdout:,
        timer:
      )
    end

    let(:load_config_config) do
      expected_cli_config.with(
        mutation: Mutant::Mutation::Config::DEFAULT.merge(expected_cli_config.mutation),
        usage:    Mutant::Usage::Opensource.new
      )
    end

    let(:load_config_result) do
      Mutant::Either::Right.new(load_config_config)
    end

    def apply
      described_class.parse(
        arguments: Marshal.load(Marshal.dump(arguments)),
        world:
      )
    end

    before do
      allow(stderr)
        .to receive(:puts) { |message| events << [:stderr, :puts, message] }

      allow(stderr)
        .to receive(:write) { |message| events << [:stderr, :write, message] }

      allow(stdout)
        .to receive(:puts) { |message| events << [:stdout, :puts, message] }

      allow(stdout)
        .to receive(:write) { |message| events << [:stdout, :write, message] }
    end

    shared_examples 'CLI run' do
      it 'performs expected events' do
        apply.from_right.call

        expect(YAML.dump(events)).to eql(YAML.dump(expected_events))
      end

      it 'exits with expected value' do
        expect(apply.from_right.call).to be(expected_exit)
      end

      it 'sets expected print_profile flag' do
        expect(apply.from_right.print_profile?).to be(expected_print_profile)
      end

      it 'sets expected zombie flag' do
        expect(apply.from_right.zombie?).to be(expected_zombie)
      end

      context 'with loaded config not exactly equal cli config' do
        let(:load_config_config) { super().with(jobs: 10) }
        let(:boostrap_config)    { load_config_config     }

        it 'uses the modified config for bootstrappin' do
          apply.from_right.call

          expect(YAML.dump(events)).to eql(YAML.dump(expected_events))
        end
      end
    end

    @tests = []

    @test_klass =
      Class.new do
        include Unparser::Anima.new(
          :arguments,
          :expected_events,
          :expected_exit,
          :expected_print_profile,
          :expected_zombie
        )
      end

    def self.make
      @tests << @test_klass.new(yield)
    end

    # rubocop:disable Metrics/MethodLength
    def self.main_body
      <<~MESSAGE.strip
        usage: mutant <run|environment|util> [options]

        Summary: mutation testing engine main command

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified

        Available subcommands:

        run         - Run code analysis
        environment - Environment subcommands
        util        - Utility subcommands
      MESSAGE
    end
    # rubocop:enable Metrics/MethodLength

    context 'empty arguments' do
      message = <<~MESSAGE
        mutant: Missing required subcommand!

        #{main_body}
      MESSAGE

      let(:arguments) { [] }

      it 'returns expected message' do
        expect(apply).to eql(left(message))
      end
    end

    context 'unknown subcommand' do
      message = <<~MESSAGE
        mutant: Cannot find subcommand "unknown-subcommand"

        #{main_body}
      MESSAGE

      let(:arguments) { %w[unknown-subcommand] }

      it 'returns expected message' do
        expect(apply).to eql(left(message))
      end
    end

    context 'unknown subcommand' do
      message = <<~MESSAGE
        mutant: invalid option: --unknown-option

        #{main_body}
      MESSAGE

      let(:arguments) { %w[--unknown-option foo] }

      it 'returns expected message' do
        expect(apply).to eql(left(message))
      end
    end

    make do
      message = "#{main_body}\n"

      {
        arguments:              %w[--help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = "#{main_body}\n"

      {
        arguments:              %w[--zombie --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        true
      }
    end

    make do
      {
        arguments:              %w[--version],
        expected_events:        [[:stdout, :puts, "mutant-#{Mutant::VERSION}"]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    context 'missing required subcommand' do
      message = <<~MESSAGE
        mutant environment: Missing required subcommand!

        usage: mutant environment <subject|show|irb|test> [options]

        Summary: Environment subcommands

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified

        Available subcommands:

        subject - Subject subcommands
        show    - Display environment without coverage analysis
        irb     - Run irb with mutant environment loaded
        test    - test subcommands
      MESSAGE

      let(:arguments) { %w[environment] }

      it 'returns expected message' do
        expect(apply).to eql(left(message))
      end
    end

    make do
      message = <<~MESSAGE
        usage: mutant environment irb [options]

        Summary: Run irb with mutant environment loaded

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


        Environment:
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME
                --env KEY=VALUE              Set environment variable


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            deprecated alias for --integration
                --integration NAME           Use test integration with NAME
                --integration-argument ARGUMENT
                                             Pass ARGUMENT to integration


        Matcher:
                --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                --start-subject EXPRESSION   Start mutation testing at a specific subject
                --since REVISION             Only select subjects touched since REVISION


        Reporting:
                --print-warnings             Print warnings


        Usage:
                --usage USAGE_TYPE           License usage: opensource|commercial
      MESSAGE

      {
        arguments:              %w[environment irb --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant run [options]

        Summary: Run code analysis

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


        Environment:
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME
                --env KEY=VALUE              Set environment variable


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            deprecated alias for --integration
                --integration NAME           Use test integration with NAME
                --integration-argument ARGUMENT
                                             Pass ARGUMENT to integration


        Matcher:
                --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                --start-subject EXPRESSION   Start mutation testing at a specific subject
                --since REVISION             Only select subjects touched since REVISION


        Reporting:
                --print-warnings             Print warnings


        Usage:
                --usage USAGE_TYPE           License usage: opensource|commercial
      MESSAGE

      {
        arguments:              %w[run --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant run [options]

        Summary: Run code analysis

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


        Environment:
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME
                --env KEY=VALUE              Set environment variable


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            deprecated alias for --integration
                --integration NAME           Use test integration with NAME
                --integration-argument ARGUMENT
                                             Pass ARGUMENT to integration


        Matcher:
                --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                --start-subject EXPRESSION   Start mutation testing at a specific subject
                --since REVISION             Only select subjects touched since REVISION


        Reporting:
                --print-warnings             Print warnings


        Usage:
                --usage USAGE_TYPE           License usage: opensource|commercial
      MESSAGE

      {
        arguments:              %w[--profile run --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: true,
        expected_zombie:        false
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant run [options]

        Summary: Run code analysis

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


        Environment:
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME
                --env KEY=VALUE              Set environment variable


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            deprecated alias for --integration
                --integration NAME           Use test integration with NAME
                --integration-argument ARGUMENT
                                             Pass ARGUMENT to integration


        Matcher:
                --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                --start-subject EXPRESSION   Start mutation testing at a specific subject
                --since REVISION             Only select subjects touched since REVISION


        Reporting:
                --print-warnings             Print warnings


        Usage:
                --usage USAGE_TYPE           License usage: opensource|commercial
      MESSAGE

      {
        arguments:              %w[--zombie run --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        true
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant util <mutation> [options]

        Summary: Utility subcommands

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified

        Available subcommands:

        mutation - Print mutations of a code snippet
      MESSAGE

      {
        arguments:              %w[util --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant util mutation [options]

        Summary: Print mutations of a code snippet

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


            -e, --evaluate SOURCE
            -i, --ignore-pattern AST_PATTERN
      MESSAGE

      {
        arguments:              %w[util mutation --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~'MESSAGE'
        @@ -1 +1 @@
        -true
        +false
      MESSAGE

      {
        arguments:              %w[util mutation -e true],
        expected_events:        [
          [:stdout, :puts, '<cli-source>'],
          [:stdout, :write, message]
        ],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      {
        arguments:              %w[util mutation -e true -i true],
        expected_events:        [
          [:stdout, :puts, '<cli-source>']
        ],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      {
        arguments:              %w[util mutation -e true -i foo],
        expected_events:        [
          [:stderr, :puts, <<~'MESSAGE'.strip]
            Expected valid node type got: foo
            foo
            ^^^
          MESSAGE
        ],
        expected_exit:          false,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~'MESSAGE'
        @@ -1 +1 @@
        -true
        +false
      MESSAGE

      {
        arguments:              %w[util mutation test_app/simple.rb],
        expected_events:        [
          [:stdout, :puts, 'file:test_app/simple.rb'],
          [:stdout, :write, message]
        ],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    make do
      message = <<~MESSAGE
        usage: mutant environment <subject|show|irb|test> [options]

        Summary: Environment subcommands

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified

        Available subcommands:

        subject - Subject subcommands
        show    - Display environment without coverage analysis
        irb     - Run irb with mutant environment loaded
        test    - test subcommands
      MESSAGE

      {
        arguments:              %w[environment --help],
        expected_events:        [[:stdout, :puts, message]],
        expected_exit:          true,
        expected_print_profile: false,
        expected_zombie:        false
      }
    end

    context 'pathname with null bytes' do
      let(:arguments) { %w[util mutation] + ["\0"] }

      it 'returns expected message' do
        expect(apply).to eql(left('pathname contains null byte'))
      end
    end

    context 'cannot open ruby file' do
      let(:arguments) { %w[util mutation does-not-exist.rb] }

      it 'returns expected message' do
        expect(apply).to eql(left('Cannot read file: No such file or directory @ rb_sysopen - does-not-exist.rb'))
      end
    end

    @tests.each do |example|
      context example.arguments.inspect do
        example.to_h.each do |key, value|
          let(key) { value }
        end

        include_examples 'CLI run'
      end
    end

    shared_context 'environment' do
      let(:arguments)            { %w[run]                                              }
      let(:bootstrap_result)     { right(env)                                           }
      let(:env_result)           { instance_double(Mutant::Result::Env, success?: true) }
      let(:expected_exit)        { true                                                 }
      let(:runner_result)        { right(env_result)                                    }
      let(:subjects)             { [subject_a]                                          }

      let(:test_a) { instance_double(Mutant::Test, identification: 'test-a') }
      let(:test_b) { instance_double(Mutant::Test, identification: 'test-b') }
      let(:test_c) { instance_double(Mutant::Test, identification: 'test-c') }

      let(:available_tests) { [test_a, test_b] }

      let(:bootstrap_config) do
        load_config_result.from_right
      end

      let(:expected_cli_config) do
        Mutant::Config::DEFAULT.with(
          coverage_criteria: Mutant::Config::CoverageCriteria::EMPTY
        )
      end

      let(:env) do
        config = bootstrap_config.with(
          jobs:     nil,
          reporter: Mutant::Reporter::CLI.build(stdout)
        )

        Mutant::Env.empty(world, config)
          .with(
            integration: instance_double(
              Mutant::Integration,
              all_tests:       [test_a, test_b, test_c],
              available_tests:
            ),
            subjects:
          )
      end

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        Object
        )
      end

      let(:constant_scope) do
        Mutant::Context::ConstantScope::None.new
      end

      let(:subject_a) do
        Mutant::Subject::Method::Instance.new(
          config:     Mutant::Subject::Config::DEFAULT,
          context:    Mutant::Context.new(constant_scope:, scope:, source_path: 'subject.rb'),
          node:       s(:def, :send, s(:args), nil),
          visibility: :public
        )
      end

      before do
        allow(Mutant::Config).to receive(:load) do |**attributes|
          events << [:load_config, attributes.inspect]
          load_config_result
        end

        allow(world).to receive(:record) do |name, &block|
          events << [:record, name]
          block.call
        end

        allow(Mutant::Bootstrap).to receive(:call) do |env|
          events << [:bootstrap, env.inspect]
          bootstrap_result
        end

        allow(Mutant::Bootstrap).to receive(:call_test) do |env|
          events << [:test_bootstrap, env.inspect]
          bootstrap_result
        end

        allow(Mutant::Mutation::Runner).to receive(:call) do |env|
          events << [:runner, env.inspect]
          runner_result
        end

        allow(Mutant::Test::Runner).to receive(:call) do |env|
          events << [:test_runner, env.inspect]
          runner_result
        end

        allow(kernel).to receive(:sleep) do |time|
          events << [:sleep, time]
          time
        end

        allow(stdout).to receive(:write) do |message|
          events << [:write, message]
          nil
        end
      end
    end

    context 'util mutation invalid round trip, all failures' do
      include_context 'environment'

      let(:arguments) { %w[util mutation -e true -e true] }

      let(:expected_exit) { false }

      let(:expected_events) do
        [
          [
            :stdout,
            :puts,
            '<cli-source>'
          ],
          [
            :stdout,
            :puts,
            '<generation-error-report>'

          ],
          [
            :stdout,
            :puts,
            '<cli-source>'
          ],
          [
            :stdout,
            :puts,
            '<generation-error-report>'

          ],
          [
            :stderr,
            :puts,
            'Invalid mutation detected!'
          ]
        ]
      end

      before do
        # rubocop:disable Lint/UnusedBlockArgument
        allow(Mutant::Mutation::Evil).to receive(:from_node) do |subject:, node:|
          {
            s(:false) => left(
              instance_double(
                Mutant::Mutation::GenerationError,
                report: '<generation-error-report>'
              )
            )
          }.fetch(node)
        end
      end

      include_examples 'CLI run'
    end

    context 'util mutation opn invalid round trip, some failures' do
      include_context 'environment'

      let(:arguments) { %w[util mutation -e 1 -e true] }

      let(:expected_exit) { false }

      let(:expected_events) do
        [
          [
            :stdout,
            :puts,
            '<cli-source>'
          ],
          [
            :stdout,
            :puts,
            '<generation-error-report>'
          ],
          [
            :write,
            <<~'MESSAGE'
              @@ -1 +1 @@
              -1
              +0
            MESSAGE
          ],
          [
            :write,
            <<~'MESSAGE'
              @@ -1 +1 @@
              -1
              +2
            MESSAGE
          ],
          [
            :stdout,
            :puts,
            '<cli-source>'
          ],
          [
            :write,
            <<~'MESSAGE'
              @@ -1 +1 @@
              -true
              +false
            MESSAGE
          ],
          [
            :stderr,
            :puts,
            'Invalid mutation detected!'
          ]
        ]
      end

      before do
        allow(Mutant::Mutation::Evil).to receive(:from_node) do |subject:, node:|
          {
            s(:false)  => right(
              Mutant::Mutation::Evil.new(
                node:    s(:false),
                source:  'false',
                subject: subject
              )
            ),
            s(:int, 0) => right(
              Mutant::Mutation::Evil.new(
                node:    s(:int, 0),
                source:  '0',
                subject: subject
              )
            ),
            s(:int, 2) => right(
              Mutant::Mutation::Evil.new(
                node:    s(:int, 0),
                source:  '2',
                subject: subject
              )
            ),
            s(:nil)    => left(
              instance_double(
                Mutant::Mutation::GenerationError,
                report: '<generation-error-report>'
              )
            )
          }.fetch(node)
        end
      end

      include_examples 'CLI run'
    end

    context 'environment irb' do
      include_context 'environment'

      before do
        allow(TOPLEVEL_BINDING).to receive(:irb) do
          events << :irb_execution
        end
      end

      let(:arguments) { %w[environment irb] }

      context 'without additional arguments' do
        let(:expected_exit) { true }

        let(:expected_events) do
          [
            %i[
              record
              config
            ],
            [
              :load_config,
              { cli_config: expected_cli_config, world: }.inspect
            ],
            [
              :bootstrap,
              Mutant::Env.empty(world, bootstrap_config).inspect
            ],
            :irb_execution
          ]
        end

        include_examples 'CLI run'
      end
    end

    shared_examples 'with additional test arguments' do
      context 'with additioanl arguments' do
        let(:arguments) { super() << 'spec/unit' }

        let(:expected_cli_config) do
          config = super()

          config.with(integration: config.integration.with(arguments: %w[spec/unit]))
        end

        include_examples 'CLI run'
      end
    end

    context 'environment test list' do
      include_context 'environment'

      let(:arguments) { %w[environment test list] }

      let(:expected_events) do
        [
          %i[
            record
            config
          ],
          [
            :load_config,
            { cli_config: expected_cli_config, world: }.inspect
          ],
          [
            :test_bootstrap,
            Mutant::Env.empty(world, bootstrap_config).inspect
          ],
          [
            :stdout,
            :puts,
            'All tests in environment: 3'
          ],
          [
            :stdout,
            :puts,
            'test-a'
          ],
          [
            :stdout,
            :puts,
            'test-b'
          ],
          [
            :stdout,
            :puts,
            'test-c'
          ]
        ]
      end

      context 'without additional arguments' do
        let(:expected_exit) { true }

        include_examples 'CLI run'
      end

      include_examples 'with additional test arguments'
    end

    context 'environment test run' do
      include_context 'environment'

      let(:arguments) { %w[environment test run] }

      let(:expected_events) do
        [
          %i[
            record
            config
          ],
          [
            :load_config,
            { cli_config: expected_cli_config, world: }.inspect
          ],
          [
            :test_bootstrap,
            Mutant::Env.empty(world, bootstrap_config).inspect
          ],
          [
            :test_runner,
            env.inspect
          ]
        ]
      end

      context 'without additional arguments' do
        let(:expected_exit) { true }

        context 'when tests fail' do
          let(:env_result)    { instance_double(Mutant::Result::Env, success?: false) }
          let(:expected_exit) { false }

          let(:expected_events) do
            super() << [
              :stderr,
              :puts,
              'Test failures, exiting nonzero!'
            ]
          end

          include_examples 'CLI run'
        end

        context 'when tests succeed' do
          include_examples 'CLI run'
        end
      end

      include_examples 'with additional test arguments'
    end

    context 'environment subject list --print-warnings' do
      include_context 'environment'

      let(:arguments) { %w[environment subject list --print-warnings] }

      let(:expected_exit) { true }

      let(:expected_events) do
        [
          %i[
            record
            config
          ],
          [
            :load_config,
            {
              cli_config: expected_cli_config.with(
                reporter: expected_cli_config.reporter.with(print_warnings: true)
              ),
              world:
            }.inspect
          ],
          [
            :bootstrap,
            Mutant::Env.empty(world, bootstrap_config).inspect
          ],
          [
            :stdout,
            :puts,
            'Subjects in environment: 1'
          ],
          [
            :stdout,
            :puts,
            'Object#send'
          ]
        ]
      end

      include_examples 'CLI run'
    end

    context 'environment subject list' do
      include_context 'environment'

      let(:arguments) { %w[environment subject list] }

      context 'without additional arguments' do
        let(:expected_exit) { true }

        let(:expected_events) do
          [
            %i[
              record
              config
            ],
            [
              :load_config,
              { cli_config: expected_cli_config, world: }.inspect
            ],
            [
              :bootstrap,
              Mutant::Env.empty(world, bootstrap_config).inspect
            ],
            [
              :stdout,
              :puts,
              'Subjects in environment: 1'
            ],
            [
              :stdout,
              :puts,
              'Object#send'
            ]
          ]
        end

        include_examples 'CLI run'
      end
    end

    context 'environment show' do
      include_context 'environment'

      let(:arguments) { %w[environment show] }

      let(:expected_message) do
         <<~'MESSAGE'
           Mutant environment:
           Usage:           opensource
           Matcher:         #<Mutant::Matcher::Config empty>
           Integration:     null
           Jobs:            auto
           Includes:        []
           Requires:        []
           Operators:       light
           Subjects:        1
           All-Tests:       3
           Available-Tests: 2
           Selected-Tests:  0
           Tests/Subject:   0.00 avg
           Mutations:       0
         MESSAGE
      end

      context 'without additional arguments' do
        let(:expected_exit) { true }

        let(:expected_events) do
          [
            %i[
              record
              config
            ],
            [
              :load_config,
              { cli_config: expected_cli_config, world: }.inspect
            ],
            [
              :bootstrap,
              Mutant::Env.empty(world, bootstrap_config).inspect
            ],
            [
              :write,
              expected_message
            ]
          ]
        end

        include_examples 'CLI run'
      end
    end

    context 'run' do
      include_context 'environment'

      let(:expected_events) do
        [
          %i[
            record
            config
          ],
          [
            :load_config,
            { cli_config: expected_cli_config, world: }.inspect
          ],
          [
            :bootstrap,
            Mutant::Env.empty(world, bootstrap_config).inspect
          ],
          [
            :runner,
            env.inspect
          ]
        ]
      end

      context 'on runner fail' do
        let(:expected_exit) { false                  }
        let(:runner_result) { left('runner failure') }

        let(:expected_events) do
          [
            *super(),
            [
              :stderr,
              :puts,
              'runner failure'
            ]
          ]
        end

        include_examples 'CLI run'
      end

      context 'on runner success with unsuccessful result' do
        context 'on alive mutations' do
          let(:expected_exit) { false             }
          let(:runner_result) { right(env_result) }

          let(:env_result) do
            instance_double(
              Mutant::Result::Env,
              success?: false
            )
          end

          let(:expected_events) do
            [
              *super(),
              [
                :stderr,
                :puts,
                'Uncovered mutations detected, exiting nonzero!'
              ]
            ]
          end

          include_examples 'CLI run'
        end

        context 'on not having found tests' do
          let(:available_tests) { [] }

          let(:expected_events) do
            [
              *super()[..-2],
              [
                :stderr,
                :puts,
                Mutant::CLI::Command::Environment::Run::NO_TESTS_MESSAGE
              ]
            ]
          end

          let(:expected_exit) { false }

          include_examples 'CLI run'
        end
      end

      context 'with valid subject expression' do
        let(:arguments) { super() + ['CLISubject'] }

        let(:expected_cli_config) do
          super().with(
            matcher: super().matcher.with(
              subjects: expected_bootstrap_subjects
            )
          )
        end

        let(:expected_bootstrap_subjects) { [parse_expression('CLISubject')] }

        include_examples 'CLI run'
      end

      context 'on invalid --usage' do
        let(:arguments) { %w[run --usage invalid] }

        it 'returns expected error' do
          expect(apply).to eql(left(<<~"MESSAGE"))
            mutant run: invalid argument: --usage invalid

            usage: mutant run [options]

            Summary: Run code analysis

            mutant version: #{Mutant::VERSION}

            Global Options:

                    --help                       Print help
                    --version                    Print mutants version
                    --profile                    Profile mutant execution
                    --zombie                     Run mutant zombified


            Environment:
                -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
                -r, --require NAME               Require file with NAME
                    --env KEY=VALUE              Set environment variable


            Runner:
                    --fail-fast                  Fail fast
                -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
                -t, --mutation-timeout NUMBER    Per mutation analysis timeout


            Integration:
                    --use INTEGRATION            deprecated alias for --integration
                    --integration NAME           Use test integration with NAME
                    --integration-argument ARGUMENT
                                                 Pass ARGUMENT to integration


            Matcher:
                    --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                    --start-subject EXPRESSION   Start mutation testing at a specific subject
                    --since REVISION             Only select subjects touched since REVISION


            Reporting:
                    --print-warnings             Print warnings


            Usage:
                    --usage USAGE_TYPE           License usage: opensource|commercial
          MESSAGE
        end
      end

      context 'on --usage commercial' do
        let(:arguments) { %w[run --usage opensource] }

        let(:expected_cli_config) do
          super().with(usage: Mutant::Usage::Opensource.new)
        end

        include_examples 'CLI run'
      end

      context 'on absent --usage' do
        let(:arguments)     { %w[run] }
        let(:expected_exit) { false   }

        let(:load_config_config) do
          expected_cli_config.with(
            mutation: Mutant::Mutation::Config::DEFAULT.merge(expected_cli_config.mutation),
            usage:    Mutant::Usage::Unknown.new
          )
        end

        let(:expected_events) do
          [
            %i[
              record
              config
            ],
            [
              :load_config,
              { cli_config: expected_cli_config, world: }.inspect
            ],
            [
              :bootstrap,
              Mutant::Env.empty(world, bootstrap_config).inspect
            ],
            [
              :stderr,
              :puts,
              Mutant::Usage::Unknown::MESSAGE
            ]
          ]
        end

        include_examples 'CLI run'
      end

      context 'with valid start-subject expression' do
        let(:arguments) do
          super() + ['--start-subject', 'Foo#bar', '--start-subject', 'Foo#baz']
        end

        let(:expected_cli_config) do
          super().with(
            matcher: super().matcher.with(
              start_expressions: %w[Foo#bar Foo#baz].map(&method(:parse_expression))
            )
          )
        end

        include_examples 'CLI run'
      end

      context 'with valid ignore-subject expression' do
        let(:arguments) do
          super() + ['--ignore-subject', 'Foo#bar', '--ignore-subject', 'Foo#baz']
        end

        let(:expected_cli_config) do
          super().with(
            matcher: super().matcher.with(
              ignore: %w[Foo#bar Foo#baz].map(&method(:parse_expression))
            )
          )
        end

        include_examples 'CLI run'
      end

      context 'with --include option' do
        let(:arguments) do
          super() + %w[
            --include include-cli-a
            --include include-cli-b
          ]
        end

        let(:expected_cli_config) do
          super().with(
            includes: %w[
              include-cli-a
              include-cli-b
            ]
          )
        end

        include_examples 'CLI run'
      end

      context 'with --require option' do
        let(:arguments) { super() + %w[--require require-cli] }

        let(:expected_cli_config) do
          super().with(
            requires: %w[require-cli]
          )
        end

        include_examples 'CLI run'
      end

      context 'with --env option' do
        let(:arguments) { super() + %W[--env #{argument}] }

        context 'on valid env syntax' do
          let(:argument) { 'foo=bar' }

          let(:expected_cli_config) do
            super().with(environment_variables: { 'foo' => 'bar' })
          end

          include_examples 'CLI run'
        end

        context 'on invalid env syntax' do
          let(:argument) { 'foobar' }

          it 'raises expected error' do
            expect { apply }.to raise_error(RuntimeError, 'Invalid env variable: "foobar"')
          end
        end
      end

      context 'with --jobs option' do
        let(:arguments)           { super() + %w[--jobs 10] }
        let(:expected_cli_config) { super().with(jobs: 10)  }

        include_examples 'CLI run'
      end

      context 'with --mutation-timeout option' do
        let(:arguments) { super() + %w[--mutation-timeout 10] }

        let(:expected_cli_config) do
          super().with(mutation: super().mutation.with(timeout: 10.0))
        end

        include_examples 'CLI run'
      end

      context 'with --fail-fast option' do
        let(:arguments)           { super() + %w[--fail-fast]     }
        let(:expected_cli_config) { super().with(fail_fast: true) }

        include_examples 'CLI run'
      end

      context 'with --use option' do
        let(:arguments) { super() + ['--use', 'cli-integration'] }

        let(:expected_cli_config) do
          super().with(integration: super().integration.with(name: 'cli-integration'))
        end

        include_examples 'CLI run'
      end

      context 'with --integration option' do
        let(:arguments) { super() + ['--integration', 'cli-integration'] }

        let(:expected_cli_config) do
          super().with(integration: super().integration.with(name: 'cli-integration'))
        end

        include_examples 'CLI run'
      end

      context 'with --integration-argument option' do
        let(:arguments) do
          super() + %w[
            --integration-argument cli-integration-argument-a
            --integration-argument cli-integration-argument-b
          ]
        end

        let(:expected_cli_config) do
          super().with(
            integration: super().integration.with(
              arguments: %w[
                cli-integration-argument-a
                cli-integration-argument-b
              ]
            )
          )
        end

        include_examples 'CLI run'
      end

      context 'with --since option' do
        let(:arguments) { super() + ['--since', 'reference'] }

        let(:expected_cli_config) do
          diff = Mutant::Repository::Diff.new(to: 'reference', world:)

          super().with(matcher: super().matcher.with(diffs: [diff]))
        end

        include_examples 'CLI run'
      end
    end
  end
end
