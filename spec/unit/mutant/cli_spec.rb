# frozen_string_literal: true

RSpec.describe Mutant::CLI do
  describe '.parse' do
    let(:env_config)    { Mutant::Config::DEFAULT.with(jobs: 4) }
    let(:events)        { []                                    }
    let(:expect_zombie) { false                                 }
    let(:kernel)        { class_double(Kernel)                  }
    let(:stderr)        { instance_double(IO, :stderr)          }
    let(:stdout)        { instance_double(IO, :stdout)          }
    let(:timer)         { instance_double(Mutant::Timer)        }

    let(:world) do
      instance_double(
        Mutant::World,
        kernel: kernel,
        stderr: stderr,
        stdout: stdout,
        timer:  timer
      )
    end

    def apply
      described_class.parse(
        arguments: Marshal.load(Marshal.dump(arguments)),
        world:     world
      )
    end

    before do
      allow(stderr)
        .to receive(:puts) { |message| events << [:stderr, :puts, message] }

      allow(stdout)
        .to receive(:puts) { |message| events << [:stdout, :puts, message] }

      allow(Mutant::Config).to receive_messages(env: env_config)
    end

    shared_examples 'CLI run' do
      it 'performs expected events' do
        apply.call

        expect(YAML.dump(events)).to eql(YAML.dump(expected_events))
      end

      it 'exits with expected value' do
        expect(apply.call).to be(expected_exit)
      end

      it 'sets expected zombie flag' do
        expect(apply.zombie?).to be(expect_zombie)
      end
    end

    shared_context 'license validation' do
      let(:license_validation_event) do
        [:license, :apply, world]
      end

      before do
        allow(Mutant::License).to receive(:apply) do |world|
          events << [:license, :apply, world]
          license_result
        end
      end
    end

    @tests = []

    @test_klass =
      Class.new do
        include Anima.new(:arguments, :expected_exit, :expected_events, :expected_zombie)
      end

    def self.make
      @tests << @test_klass.new(yield)
    end

    def self.main_body
      <<~'MESSAGE'.strip
        usage: mutant <run|environment|subscription> [options]

        Summary: mutation testing engine main command

        Global Options:

                --help                       Print help
                --version                    Print mutants version

        Available subcommands:

        run          - Run code analysis
        environment  - Environment subcommands
        subscription - Subscription subcommands
      MESSAGE
    end

    make do
      message = <<~MESSAGE
        mutant: Missing required subcommand!

        #{main_body}
      MESSAGE

      {
        arguments:       %w[],
        expected_events: [[:stderr, :puts, message]],
        expected_exit:   false,
        expected_zombie: false
      }
    end

    make do
      message = <<~MESSAGE
        mutant: Cannot find subcommand "unknown-subcommand"

        #{main_body}
      MESSAGE

      {
        arguments:       %w[unknown-subcommand],
        expected_events: [[:stderr, :puts, message]],
        expected_exit:   false,
        expected_zombie: false
      }
    end

    make do
      message = <<~MESSAGE
        mutant: invalid option: --unknown-option

        #{main_body}
      MESSAGE

      {
        arguments:       %w[--unknown-option foo],
        expected_events: [[:stderr, :puts, message]],
        expected_exit:   false,
        expected_zombie: false
      }
    end

    make do
      message = "#{main_body}\n"

      {
        arguments:       %w[--help],
        expected_events: [[:stdout, :puts, message]],
        expected_exit:   true,
        expected_zombie: false
      }
    end

    make do
      {
        arguments:       %w[--version],
        expected_events: [[:stdout, :puts, "mutant-#{Mutant::VERSION}"]],
        expected_exit:   true,
        expected_zombie: false
      }
    end

    make do
      message = <<~'MESSAGE'
        mutant subscription: Missing required subcommand!

        usage: mutant subscription <show|test> [options]

        Summary: Subscription subcommands

        Global Options:

                --help                       Print help
                --version                    Print mutants version

        Available subcommands:

        show - Show subscription status
        test - Silently validates subscription, exits accordingly
      MESSAGE

      {
        arguments:       %w[subscription],
        expected_events: [[:stderr, :puts, message]],
        expected_exit:   false,
        expected_zombie: false
      }
    end

    make do
      message = 'mutant subscription show: Does not expect extra arguments'

      {
        arguments:       %w[subscription show extra-argument],
        expected_events: [[:stderr, :puts, message]],
        expected_exit:   false,
        expected_zombie: false
      }
    end

    make do
      message = <<~'MESSAGE'
        usage: mutant subscription show [options]

        Summary: Show subscription status

        Global Options:

                --help                       Print help
                --version                    Print mutants version
      MESSAGE

      {
        arguments:       %w[subscription show --help],
        expected_events: [[:stdout, :puts, message]],
        expected_exit:   true,
        expected_zombie: false
      }
    end

    make do
      message = <<~'MESSAGE'
        usage: mutant run [options]

        Summary: Run code analysis

        Global Options:

                --help                       Print help
                --version                    Print mutants version


        Environment:
                --zombie                     Run mutant zombified
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            Use INTEGRATION to kill mutations


        Matcher:
                --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                --start-subject EXPRESSION   Start mutation testing at a specific subject
                --since REVISION             Only select subjects touched since REVISION
      MESSAGE

      {
        arguments:       %w[run --help],
        expected_events: [[:stdout, :puts, message]],
        expected_exit:   true,
        expected_zombie: false
      }
    end

    @tests.each do |example|
      context example.arguments.inspect do
        example.to_h.each do |key, value|
          let(key) { value }
        end

        include_examples 'CLI run'
      end
    end

    context 'subscription show' do
      let(:arguments) { %w[subscription show] }

      include_context 'license validation'

      context 'on valid license' do
        let(:expected_exit)  { true                                      }
        let(:license_result) { MPrelude::Either::Right.new(subscription) }

        let(:expected_events) do
          [
            license_validation_event,
            [:stdout, :puts, 'License-Description']
          ]
        end

        let(:subscription) do
          instance_double(
            Mutant::License::Subscription,
            description: 'License-Description'
          )
        end

        include_examples 'CLI run'
      end

      context 'on invalid license' do
        let(:expected_exit)  { false                                       }
        let(:license_result) { MPrelude::Either::Left.new('error-message') }

        let(:expected_events) do
          [
            license_validation_event,
            [:stderr, :puts, 'error-message']
          ]
        end

        include_examples 'CLI run'
      end
    end

    context 'license display test' do
      let(:arguments) { %w[subscription test] }

      let(:expected_events) do
        [ [:license, :apply, world ] ]
      end

      include_context 'license validation'

      context 'on valid license' do
        let(:expected_exit)  { true                                      }
        let(:license_result) { MPrelude::Either::Right.new(subscription) }

        let(:subscription) do
          instance_double(
            Mutant::License::Subscription,
            description: 'License-Description'
          )
        end

        include_examples 'CLI run'
      end

      context 'on invalid license' do
        let(:expected_exit)   { false                                       }
        let(:license_result)  { MPrelude::Either::Left.new('error-message') }

        include_examples 'CLI run'
      end
    end

    shared_context 'environment' do
      let(:arguments)          { %w[run]                                              }
      let(:bootstrap_config)   { env_config.merge(file_config).expand_defaults        }
      let(:bootstrap_result)   { MPrelude::Either::Right.new(env)                     }
      let(:env_result)         { instance_double(Mutant::Result::Env, success?: true) }
      let(:expected_events)    { [license_validation_event]                           }
      let(:expected_exit)      { true                                                 }
      let(:file_config_result) { MPrelude::Either::Right.new(file_config)             }
      let(:license_result)     { MPrelude::Either::Right.new(subscription)            }
      let(:runner_result)      { MPrelude::Either::Right.new(env_result)              }

      let(:env) do
        config = Mutant::Config::DEFAULT.with(
          reporter: Mutant::Reporter::CLI.build(stdout)
        )

        Mutant::Env.empty(world, config)
      end

      let(:file_config) do
        Mutant::Config::DEFAULT.with(
          integration:      'file-integration',
          includes:         %w[include-file],
          requires:         %w[require-file],
          mutation_timeout: 5
        )
      end

      include_context 'license validation'

      context 'with invalid expressions' do
        let(:arguments)     { super() + [''] }
        let(:expected_exit) { false          }

        let(:expected_events) do
          [
            [:stderr, :puts, 'Expression: "" is invalid']
          ]
        end

        include_examples 'CLI run'
      end

      before do
        allow(Mutant::Config).to receive(:load_config_file) do |world|
          events << [:load_config_file, world]
          file_config_result
        end

        allow(Mutant::Bootstrap).to receive(:apply) do |world, config|
          events << [:bootstrap, world, config.inspect]
          bootstrap_result
        end

        allow(Mutant::Runner).to receive(:apply) do |env|
          events << [:runner, env.inspect]
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

    context 'environment show' do
      include_context 'environment'

      let(:arguments) { %w[environment show] }

      let(:expected_message) do
         <<~'MESSAGE'
           Mutant environment:
           Matcher:         #<Mutant::Matcher::Config empty>
           Integration:     null
           Jobs:            auto
           Includes:        []
           Requires:        []
           Subjects:        0
           Total-Tests:     0
           Selected-Tests:  0
           Tests/Subject:   0.00 avg
           Mutations:       0
         MESSAGE
      end

      context 'without additional arguments' do
        let(:expected_exit) { true }

        let(:expected_events) do
          [
            [
              :load_config_file,
              world
            ],
            [
              :bootstrap,
              world,
              bootstrap_config.inspect
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

      context 'on invalid license' do
        let(:expected_exit)    { true                                        }
        let(:license_result)   { MPrelude::Either::Left.new('license-error') }

        let(:expected_events) do
          [
            license_validation_event,
            [:stderr, :puts, 'license-error'],
            [:stderr, :puts, "[Mutant-License-Error]: Soft fail, continuing in 40 seconds\n"],
            [:stderr, :puts, "[Mutant-License-Error]: Next major version will enforce the license\n"],
            [:stderr, :puts, "[Mutant-License-Error]: See https://github.com/mbj/mutant#licensing\n"],
            [:sleep, 40],
            [
              :load_config_file,
              world
            ],
            [
              :bootstrap,
              world,
              bootstrap_config.inspect
            ],
            [
              :runner,
              env.inspect
            ]
          ]
        end

        include_examples 'CLI run'
      end

      context 'on valid license' do
        let(:subscription) do
          instance_double(
            Mutant::License::Subscription,
            description: 'License-Description'
          )
        end

        let(:expected_events) do
          [
            license_validation_event,
            [
              :load_config_file,
              world
            ],
            [
              :bootstrap,
              world,
              bootstrap_config.inspect
            ],
            [
              :runner,
              env.inspect
            ]
          ]
        end

        context 'on runner fail' do
          let(:expected_exit) { false }

          let(:runner_result) do
            MPrelude::Either::Left.new('runner failure')
          end

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

        context 'with valid match expression' do
          let(:arguments) { super() + ['Foo#bar'] }

          let(:bootstrap_config) do
            super().with(
              matcher: file_config.matcher.with(
                match_expressions: [parse_expression('Foo#bar')]
              )
            )
          end

          include_examples 'CLI run'
        end

        context 'with valid start-subject expression' do
          let(:arguments) do
            super() + ['--start-subject', 'Foo#bar', '--start-subject', 'Foo#baz']
          end

          let(:bootstrap_config) do
            super().with(
              matcher: file_config.matcher.with(
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

          let(:bootstrap_config) do
            super().with(
              matcher: file_config.matcher.with(
                ignore_expressions: %w[Foo#bar Foo#baz].map(&method(:parse_expression))
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

          let(:bootstrap_config) do
            super().with(
              includes: %w[
                include-file
                include-cli-a
                include-cli-b
              ]
            )
          end

          include_examples 'CLI run'
        end

        context 'with --require option' do
          let(:arguments) { super() + %w[--require require-cli] }

          let(:bootstrap_config) do
            super().with(
              requires: %w[require-file require-cli]
            )
          end

          include_examples 'CLI run'
        end

        context 'with --jobs option on absent file config' do
          let(:arguments)        { super() + %w[--jobs 10] }
          let(:bootstrap_config) { super().with(jobs: 10)  }

          include_examples 'CLI run'
        end

        context 'with --jobs option on present file config' do
          let(:arguments)        { super() + %w[--jobs 10] }
          let(:bootstrap_config) { super().with(jobs: 10)  }
          let(:file_config)      { super().with(jobs: 2)   }

          include_examples 'CLI run'
        end

        context 'without --jobs option on present file config' do
          let(:bootstrap_config) { super().with(jobs: 2) }
          let(:file_config)      { super().with(jobs: 2) }

          include_examples 'CLI run'
        end

        context 'with --mutation-timeout option' do
          let(:arguments)        { super() + %w[--mutation-timeout 10]  }
          let(:bootstrap_config) { super().with(mutation_timeout: 10.0) }

          include_examples 'CLI run'
        end

        context 'with --zombie flag' do
          let(:arguments)        { super() + %w[--zombie]     }
          let(:bootstrap_config) { super().with(zombie: true) }
          let(:expect_zombie)    { true                       }

          include_examples 'CLI run'
        end

        context 'with --fail-fast option' do
          let(:arguments)        { super() + %w[--fail-fast]     }
          let(:bootstrap_config) { super().with(fail_fast: true) }

          include_examples 'CLI run'
        end

        context 'with --use option' do
          let(:arguments)        { super() + ['--use', 'cli-integration']       }
          let(:bootstrap_config) { super().with(integration: 'cli-integration') }

          include_examples 'CLI run'
        end

        context 'without --use option' do
          let(:arguments)        { super()                                       }
          let(:bootstrap_config) { super().with(integration: 'file-integration') }

          include_examples 'CLI run'
        end

        context 'coverage criterias' do
          let(:env_config)       { Mutant::Config::DEFAULT }
          let(:file_config)      { Mutant::Config::DEFAULT }

          context 'without coverage criterias in env or file' do
            let(:bootstrap_config) { Mutant::Config::DEFAULT.expand_defaults }

            include_examples 'CLI run'
          end

          context 'with coverage criterias in file' do
            let(:file_config) do
              Mutant::Config::DEFAULT.with(
                coverage_criteria: Mutant::Config::CoverageCriteria::DEFAULT.with(
                  timeout: true
                )
              )
            end

            let(:bootstrap_config) { file_config.expand_defaults }

            include_examples 'CLI run'
          end
        end

        context 'with --since option' do
          let(:arguments) { super() + ['--since', 'reference'] }

          let(:bootstrap_config) do
            super().with(
              matcher: file_config.matcher.with(
                subject_filters: [
                  Mutant::Repository::SubjectFilter.new(
                    Mutant::Repository::Diff.new(
                      to:    'reference',
                      world: world
                    )
                  )
                ]
              )
            )
          end

          include_examples 'CLI run'
        end
      end
    end
  end
end
