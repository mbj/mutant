# frozen_string_literal: true

RSpec.describe Mutant::Bootstrap do
  let(:integration)          { instance_double(Mutant::Integration)   }
  let(:integration_name)     { instance_double(String)                }
  let(:integration_result)   { Mutant::Either::Right.new(integration) }
  let(:kernel)               { instance_double(Object, 'kernel')      }
  let(:load_path)            { %w[original]                           }
  let(:matcher_config)       { Mutant::Matcher::Config::DEFAULT       }
  let(:object_space)         { class_double(ObjectSpace)              }
  let(:object_space_modules) { []                                     }
  let(:parser)               { instance_double(Mutant::Parser)        }

  let(:world) do
    instance_double(
      Mutant::World,
      kernel:       kernel,
      load_path:    load_path,
      object_space: object_space,
      pathname:     Pathname
    )
  end

  let(:config) do
    Mutant::Config::DEFAULT.with(
      includes:    [],
      integration: integration,
      jobs:        1,
      matcher:     matcher_config,
      reporter:    instance_double(Mutant::Reporter),
      requires:    []
    )
  end

  let(:expected_env) do
    env_with_scopes.with(
      integration: integration,
      selector:    Mutant::Selector::Expression.new(integration)
    )
  end

  let(:env_empty) do
    Mutant::Env.empty(world, config)
  end

  let(:env_with_scopes) { env_empty }

  shared_examples 'expected warning' do
    let(:warns) { [] }

    before do
      allow(config.reporter).to receive(:warn, &warns.method(:<<))
    end

    it 'warns with expected warning' do
      expect { apply }.to change(warns, :to_a).from([]).to([expected_warning])
    end
  end

  shared_examples_for 'bootstrap call' do
    it 'returns expected env' do
      expect(apply).to eql(Mutant::Either::Right.new(expected_env))
    end

    it 'performs IO in expected sequence' do
      apply

      expect(object_space)
        .to have_received(:each_object)
        .ordered

      expect(Mutant::Integration)
        .to have_received(:setup)
        .with(env_with_scopes)
        .ordered
    end
  end

  before do
    allow(Mutant::Integration).to receive_messages(setup: integration_result)

    allow(object_space).to receive(:each_object) do |argument|
      expect(argument).to be(Module)
      object_space_modules.each
    end
  end

  describe '.apply' do
    def apply
      described_class.apply(world, config)
    end

    context 'when Module#name calls result in exceptions' do
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

      include_examples 'expected warning'
      include_examples 'bootstrap call'
    end

    context 'when Module#name calls return nil' do
      let(:anonymous_class)      { Class.new         }
      let(:object_space_modules) { [anonymous_class] }

      include_examples 'bootstrap call'
    end

    context 'when requires are configured' do
      let(:config)   { super().with(requires: %w[foo bar]) }
      let(:requires) { []                                  }

      before do
        allow(kernel).to receive(:require, &requires.method(:<<))
      end

      it 'executes requires' do
        expect { apply }.to change(requires, :to_a).from([]).to(%w[foo bar])
      end

      include_examples 'bootstrap call'
    end

    context 'when includes are configured' do
      let(:config) { super().with(includes: %w[foo bar]) }

      it 'appends to load path' do
        expect { apply }
          .to change(load_path, :to_a)
          .from(load_path.dup)
          .to(%w[original foo bar])
      end

      include_examples 'bootstrap call'
    end

    context 'when Module#name does not return a String or nil' do
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

      include_examples 'expected warning'
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
      let(:object_space_modules) { [TestApp::Literal, TestApp::Empty]                               }
      let(:match_expressions)    { object_space_modules.map(&:name).map(&method(:parse_expression)) }

      let(:matcher_config) do
        super().with(match_expressions: match_expressions)
      end

      let(:env_with_scopes) do
        env_empty.with(
          matchable_scopes: [
            Mutant::Scope.new(TestApp::Empty,   match_expressions.last),
            Mutant::Scope.new(TestApp::Literal, match_expressions.first)
          ]
        )
      end

      let(:expected_env) do
        subjects = Mutant::Matcher::Scope.new(TestApp::Literal).call(Fixtures::TEST_ENV)

        super().with(
          mutations: subjects.flat_map(&:mutations),
          subjects:  subjects
        )
      end

      include_examples 'bootstrap call'
    end
  end
end
