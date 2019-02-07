# frozen_string_literal: true

RSpec.describe Mutant::Env::Bootstrap do
  let(:integration)          { instance_double(Mutant::Integration) }
  let(:integration_class)    { instance_double(Class)               }
  let(:load_path)            { %w[original]                         }
  let(:matcher_config)       { Mutant::Matcher::Config::DEFAULT     }
  let(:object_space_modules) { []                                   }
  let(:kernel)               { instance_double(Object, 'kernel')    }

  let(:world) do
    instance_double(
      Mutant::World,
      kernel:    kernel,
      load_path: load_path,
      pathname:  Pathname
    )
  end

  let(:config) do
    Mutant::Config::DEFAULT.with(
      includes:    [],
      integration: integration_class,
      jobs:        1,
      matcher:     matcher_config,
      reporter:    instance_double(Mutant::Reporter),
      requires:    []
    )
  end

  let(:expected_env) do
    Mutant::Env.new(
      config:           config,
      integration:      integration,
      matchable_scopes: [],
      mutations:        [],
      parser:           Mutant::Parser.new,
      selector:         Mutant::Selector::Expression.new(integration),
      subjects:         [],
      world:            world
    )
  end

  shared_examples_for 'bootstrap call' do
    it 'returns expected env' do
      expect(apply).to eql(expected_env)
    end
  end

  def expect_warning
    expect(config.reporter).to receive(:warn)
      .with(expected_warning)
      .and_return(config.reporter)
  end

  before do
    expect(integration_class).to receive(:new)
      .with(config)
      .and_return(integration)

    expect(integration).to receive_messages(setup: integration)

    expect(ObjectSpace).to receive(:each_object)
      .with(Module)
      .and_return(object_space_modules.each)
  end

  describe '#warn' do
    let(:object)           { described_class.new(world, config) }
    let(:expected_warning) { instance_double(String)            }

    subject { object.warn(expected_warning) }

    before { expect_warning }

    it_behaves_like 'a command method'
  end

  describe '.call' do
    def apply
      described_class.call(world, config)
    end

    context 'when Module#name calls result in exceptions' do
      let(:object_space_modules) { [invalid_class] }

      let(:expected_warning) do
        "Class#name from: #{invalid_class} raised an error: " \
        "RuntimeError. #{Mutant::Env::SEMANTICS_MESSAGE}"
      end

      let(:invalid_class) do
        Class.new do
          def self.name
            fail
          end
        end
      end

      after do
        # Fix Class#name so other specs do not see this one
        class << invalid_class
          undef :name
          def name; end
        end
      end

      before { expect_warning }

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
        Class.new do
          def self.name
            Object
          end
        end
      end

      let(:expected_warning) do
        "Class#name from: #{invalid_class} " \
        "returned Object. #{Mutant::Env::SEMANTICS_MESSAGE}"
      end

      after do
        # Fix Class#name so other specs do not see this one
        class << invalid_class
          undef :name
          def name; end
        end
      end

      before { expect_warning }

      include_examples 'bootstrap call'
    end

    context 'when scope matches expression' do
      let(:object_space_modules) { [TestApp::Literal, TestApp::Empty]                               }
      let(:match_expressions)    { object_space_modules.map(&:name).map(&method(:parse_expression)) }

      let(:matcher_config) do
        super().with(match_expressions: match_expressions)
      end

      let(:expected_env) do
        subjects = Mutant::Matcher::Scope.new(TestApp::Literal).call(Fixtures::TEST_ENV)

        super().with(
          matchable_scopes: [
            Mutant::Scope.new(TestApp::Empty,   match_expressions.last),
            Mutant::Scope.new(TestApp::Literal, match_expressions.first)
          ],
          mutations:        subjects.flat_map(&:mutations),
          subjects:         subjects
        )
      end

      include_examples 'bootstrap call'
    end
  end
end
