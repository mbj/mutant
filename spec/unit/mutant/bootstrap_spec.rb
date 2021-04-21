# frozen_string_literal: true

RSpec.describe Mutant::Bootstrap do
  let(:env_with_scopes)      { env_initial                            }
  let(:hooks)                { instance_double(Mutant::Hooks)         }
  let(:integration)          { instance_double(Mutant::Integration)   }
  let(:integration_result)   { Mutant::Either::Right.new(integration) }
  let(:kernel)               { fake_kernel.new                        }
  let(:load_path)            { instance_double(Array, :load_path)     }
  let(:match_warnings)       { []                                     }
  let(:object_space)         { class_double(ObjectSpace)              }
  let(:object_space_modules) { []                                     }
  let(:start_expressions)    { []                                     }
  let(:subject_expressions)  { []                                     }
  let(:timer)                { instance_double(Mutant::Timer)         }

  let(:fake_kernel) do
    Class.new do
      def require(_); end
    end
  end

  let(:config) do
    Mutant::Config::DEFAULT.with(
      includes:    %w[include-a include-b],
      integration: integration,
      jobs:        1,
      matcher:     matcher_config,
      reporter:    instance_double(Mutant::Reporter),
      requires:    %w[require-a require-b]
    )
  end

  let(:matcher_config) do
    Mutant::Matcher::Config::DEFAULT.with(
      subjects:          subject_expressions,
      start_expressions: start_expressions
    )
  end

  let(:env_initial) do
    Mutant::Env.empty(world, config).with(hooks: hooks)
  end

  let(:expected_env) do
    env_with_scopes.with(
      integration: integration,
      selector:    Mutant::Selector::Expression.new(integration)
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      kernel:       kernel,
      load_path:    load_path,
      object_space: object_space,
      pathname:     Pathname,
      timer:        timer
    )
  end

  shared_examples_for 'bootstrap call' do
    it 'performs IO in expected sequence' do
      verify_events do
        expect(apply).to eql(Mutant::Either::Right.new(expected_env))
      end
    end
  end

  let(:raw_expectations) do
    [
      {
        receiver:  Mutant::Hooks,
        selector:  :load_config,
        arguments: [config],
        reaction:  { return: hooks }
      },
      {
        receiver:  hooks,
        selector:  :run,
        arguments: [:env_infection_pre, env_initial]
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
        receiver:  hooks,
        selector:  :run,
        arguments: [:env_infection_post, env_initial]
      },
      {
        receiver:  object_space,
        selector:  :each_object,
        arguments: [Module],
        reaction:  { return: object_space_modules.each }
      },
      *match_warnings,
      {
        receiver:  Mutant::Integration,
        selector:  :setup,
        arguments: [env_with_scopes],
        reaction:  { return: integration_result }

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

  describe '.call' do
    def apply
      described_class.call(world, config)
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
            Mutant::Scope.new(TestApp::Empty,   subject_expressions.last),
            Mutant::Scope.new(TestApp::Literal, subject_expressions.first)
          ]
        )
      end

      let(:expected_subjects) do
        Mutant::Matcher::Scope.new(TestApp::Literal).call(env_initial)
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
              integration: integration,
              jobs:        1,
              matcher:     Mutant::Matcher::Config::DEFAULT.with(subjects: subject_expressions),
              reporter:    instance_double(Mutant::Reporter)
            )

            Mutant::Matcher::Scope
              .new(TestApp::Literal)
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
end
