# frozen_string_literal: true

RSpec.describe Mutant::Bootstrap do
  let(:hooks)                { instance_double(Mutant::Hooks)         }
  let(:integration)          { instance_double(Mutant::Integration)   }
  let(:integration_result)   { Mutant::Either::Right.new(integration) }
  let(:kernel)               { fake_kernel.new                        }
  let(:load_path)            { instance_double(Array, :load_path)     }
  let(:object_space)         { class_double(ObjectSpace)              }
  let(:start_expressions)    { []                                     }
  let(:subject_expressions)  { []                                     }
  let(:timer)                { instance_double(Mutant::Timer)         }

  let(:config) do
    Mutant::Config::DEFAULT.with(
      environment_variables: { 'foo' => 'bar' },
      includes:              %w[include-a include-b],
      jobs:                  1,
      matcher:               matcher_config,
      reporter:              instance_double(Mutant::Reporter),
      requires:              %w[require-a require-b]
    )
  end

  let(:env_initial) do
    Mutant::Env.empty(world, config).with(hooks:)
  end

  let(:fake_kernel) do
    Class.new do
      def require(_); end
    end
  end

  let(:matcher_config) do
    Mutant::Matcher::Config::DEFAULT.with(
      subjects:          subject_expressions,
      start_expressions:
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      environment_variables: {},
      kernel:,
      load_path:,
      object_space:,
      pathname:              Pathname,
      recorder:              instance_double(Mutant::Segment::Recorder),
      timer:
    )
  end

  shared_examples_for 'bootstrap call' do
    it 'performs IO in expected sequence' do
      verify_events do
        expect(apply).to eql(Mutant::Either::Right.new(expected_env))
      end
    end
  end

  describe '#call' do
    let(:env_with_scopes) { env_initial }
    let(:match_warnings)  { []          }

    let(:expected_env) do
      env_with_scopes.with(
        integration:,
        selector:    Mutant::Selector::Expression.new(integration:)
      )
    end

    let(:raw_expectations) do
      [
        {
          receiver:  world,
          selector:  :record,
          arguments: [:bootstrap],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:load_hooks],
          reaction:  { yields: [] }
        },
        {
          receiver:  Mutant::Hooks,
          selector:  :load_config,
          arguments: [config],
          reaction:  { return: hooks }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:infect],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:hooks_env_infection_pre],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:env_infection_pre, { env: env_initial }]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:require_target],
          reaction:  { yields: [] }
        },
        {
          receiver:  world.environment_variables,
          selector:  :[]=,
          arguments: %w[foo bar]
        },
        {
          receiver:  load_path,
          selector:  :<<,
          arguments: %w[include-a]
        },
        {
          receiver:  load_path,
          selector:  :<<,
          arguments: %w[include-b]
        },
        {
          receiver:  kernel,
          selector:  :require,
          arguments: %w[require-a]
        },
        {
          receiver:  kernel,
          selector:  :require,
          arguments: %w[require-b]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:hooks_env_infection_post],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:env_infection_post, { env: env_initial }]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:matchable_scopes],
          reaction:  { yields: [] }
        },
        {
          receiver:  object_space,
          selector:  :each_object,
          arguments: [Module],
          reaction:  { return: object_space_modules.each }
        },
        *match_warnings,
        {
          receiver:  world,
          selector:  :record,
          arguments: [:subject_match],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:subject_select],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:mutation_generate],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:setup_integration],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:setup_integration_pre]
        },
        {
          receiver:  Mutant::Integration,
          selector:  :setup,
          arguments: [env_with_scopes],
          reaction:  { return: integration_result }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:setup_integration_post]
        }
      ]
    end

    def self.expect_warnings
      let(:match_warnings) do
        [
          {
            receiver:  config.reporter,
            selector:  :warn,
            arguments: [expected_warning],
            reaction:  { return: config.reporter }
          }
        ]
      end
    end

    def apply
      described_class.call(Mutant::Env.empty(world, config))
    end

    context 'when Module#name calls result in exceptions' do
      expect_warnings

      let(:object_space_modules) { [invalid_class] }

      let(:expected_warning) do
        "Object#name from: #{invalid_class} raised an error: " \
          "RuntimeError. #{Mutant::Env::SEMANTICS_MESSAGE}"
      end

      # Not really a class, but does not leak a "wrong" class
      # into later specs.
      let(:invalid_class) do
        Object.new.tap do |object|
          def object.name
            fail
          end
        end
      end

      include_examples 'bootstrap call'
    end

    context 'when Module#name calls return nil' do
      let(:anonymous_class)      { Class.new         }
      let(:object_space_modules) { [anonymous_class] }

      include_examples 'bootstrap call'
    end

    context 'when Module#name does not return a String or nil' do
      expect_warnings

      let(:object_space_modules) { [invalid_class] }

      let(:invalid_class) do
        # intentionally an object to not actually pollute object space
        Object.new.tap do |object|
          def object.name
            Object
          end
        end
      end

      let(:expected_warning) do
        "Object#name from: #{invalid_class} " \
          "returned Object. #{Mutant::Env::SEMANTICS_MESSAGE}"
      end

      include_examples 'bootstrap call'
    end

    context 'when object name cannot be parsed as expression' do
      let(:object_space_modules) { [invalid_class] }

      let(:invalid_class) do
        # intentionally an object to not actually pollute object space
        Object.new.tap do |object|
          def object.name
            'invalid expression'
          end
        end
      end

      include_examples 'bootstrap call'
    end

    context 'when scope matches expression' do
      let(:object_space_modules) do
        [TestApp::Literal, TestApp::Empty]
      end

      let(:subject_expressions) do
        object_space_modules.map(&:name).map(&method(:parse_expression))
      end

      let(:env_with_scopes) do
        env_initial.with(
          matchable_scopes: [
            Mutant::Scope.new(raw: TestApp::Empty,   expression: subject_expressions.last),
            Mutant::Scope.new(raw: TestApp::Literal, expression: subject_expressions.first)
          ]
        )
      end

      let(:scope) do
        Mutant::Scope.new(
          expression: parse_expression('TestApp::Literal'),
          raw:        TestApp::Literal
        )
      end

      let(:expected_subjects) do
        Mutant::Matcher::Scope.new(scope:).call(env_initial)
      end

      let(:expected_env) do
        super().with(
          mutations: expected_subjects.flat_map(&:mutations),
          subjects:  expected_subjects
        )
      end

      context 'without start subjects' do
        include_examples 'bootstrap call'
      end

      context 'when matcher configures a start subject' do
        context 'when the start subject fully excludes all subjects' do
          let(:start_expressions) { [parse_expression('Foo*')] }
          let(:expected_subjects) { []                         }

          include_examples 'bootstrap call'
        end

        context 'when the start subject partially excludes subjects' do
          let(:last_subject) do
            config = Mutant::Config::DEFAULT.with(
              jobs:     1,
              matcher:  Mutant::Matcher::Config::DEFAULT.with(subjects: subject_expressions),
              reporter: instance_double(Mutant::Reporter)
            )

            Mutant::Matcher::Scope
              .new(scope:)
              .call(Mutant::Env.empty(world, config)).last
          end

          let(:start_expressions) { [last_subject.expression] }

          let(:expected_subjects) do
            [last_subject]
          end

          include_examples 'bootstrap call'
        end
      end
    end
  end

  describe '#call_test' do
    def apply
      described_class.call_test(env_initial)
    end

    context 'when integration setup fails' do
      let(:integration_result) { Mutant::Either::Left.new('integration setup failed') }

      let(:raw_expectations) do
        [
          {
            receiver:  world,
            selector:  :record,
            arguments: [:bootstrap],
            reaction:  { yields: [] }
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:load_hooks],
            reaction:  { yields: [] }
          },
          {
            receiver:  Mutant::Hooks,
            selector:  :load_config,
            arguments: [config],
            reaction:  { return: hooks }
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:infect],
            reaction:  { yields: [] }
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:hooks_env_infection_pre],
            reaction:  { yields: [] }
          },
          {
            receiver:  hooks,
            selector:  :run,
            arguments: [:env_infection_pre, { env: env_initial }]
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:require_target],
            reaction:  { yields: [] }
          },
          {
            receiver:  world.environment_variables,
            selector:  :[]=,
            arguments: %w[foo bar]
          },
          {
            receiver:  load_path,
            selector:  :<<,
            arguments: %w[include-a]
          },
          {
            receiver:  load_path,
            selector:  :<<,
            arguments: %w[include-b]
          },
          {
            receiver:  kernel,
            selector:  :require,
            arguments: %w[require-a]
          },
          {
            receiver:  kernel,
            selector:  :require,
            arguments: %w[require-b]
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:hooks_env_infection_post],
            reaction:  { yields: [] }
          },
          {
            receiver:  hooks,
            selector:  :run,
            arguments: [:env_infection_post, { env: env_initial }]
          },
          {
            receiver:  world,
            selector:  :record,
            arguments: [:setup_integration],
            reaction:  { yields: [] }
          },
          {
            receiver:  hooks,
            selector:  :run,
            arguments: [:setup_integration_pre]
          },
          {
            receiver:  Mutant::Integration,
            selector:  :setup,
            arguments: [env_initial],
            reaction:  { return: integration_result }
          }
          # NOTE: setup_integration_post should NOT be called on failure
        ]
      end

      it 'does not call setup_integration_post hook' do
        verify_events do
          expect(apply).to eql(Mutant::Either::Left.new('integration setup failed'))
        end
      end
    end

    let(:expected_env) do
      env_initial.with(
        integration:,
        selector:    Mutant::Selector::Expression.new(integration:)
      )
    end

    let(:raw_expectations) do
      [
        {
          receiver:  world,
          selector:  :record,
          arguments: [:bootstrap],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:load_hooks],
          reaction:  { yields: [] }
        },
        {
          receiver:  Mutant::Hooks,
          selector:  :load_config,
          arguments: [config],
          reaction:  { return: hooks }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:infect],
          reaction:  { yields: [] }
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:hooks_env_infection_pre],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:env_infection_pre, { env: env_initial }]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:require_target],
          reaction:  { yields: [] }
        },
        {
          receiver:  world.environment_variables,
          selector:  :[]=,
          arguments: %w[foo bar]
        },
        {
          receiver:  load_path,
          selector:  :<<,
          arguments: %w[include-a]
        },
        {
          receiver:  load_path,
          selector:  :<<,
          arguments: %w[include-b]
        },
        {
          receiver:  kernel,
          selector:  :require,
          arguments: %w[require-a]
        },
        {
          receiver:  kernel,
          selector:  :require,
          arguments: %w[require-b]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:hooks_env_infection_post],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:env_infection_post, { env: env_initial }]
        },
        {
          receiver:  world,
          selector:  :record,
          arguments: [:setup_integration],
          reaction:  { yields: [] }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:setup_integration_pre]
        },
        {
          receiver:  Mutant::Integration,
          selector:  :setup,
          arguments: [env_initial],
          reaction:  { return: integration_result }
        },
        {
          receiver:  hooks,
          selector:  :run,
          arguments: [:setup_integration_post]
        }
      ]
    end

    include_examples 'bootstrap call'
  end
end
