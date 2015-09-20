# This spec is a good example for:
#
# If test look that ugly the class under test sucks.
#
# As the bootstrap needs to infect global VM state
# this is to some degree acceptable.
#
# Still the bootstrap needs to be cleaned up.
# And the change that added this warning did the groundwork.
RSpec.describe Mutant::Env::Bootstrap do
  let(:matcher_config)       { Mutant::Matcher::Config::DEFAULT     }
  let(:integration)          { instance_double(Mutant::Integration) }
  let(:integration_class)    { instance_double(Class)               }
  let(:object_space_modules) { []                                   }

  let(:config) do
    Mutant::Config::DEFAULT.with(
      jobs:        1,
      reporter:    Mutant::Reporter::Trace.new,
      includes:    [],
      requires:    [],
      integration: integration_class,
      matcher:     matcher_config
    )
  end

  let(:expected_env) do
    Mutant::Env.new(
      cache:            Mutant::Cache.new,
      subjects:         [],
      matchable_scopes: [],
      mutations:        [],
      config:           config,
      selector:         Mutant::Selector::Expression.new(integration),
      actor_env:        Mutant::Actor::Env.new(Thread),
      integration:      integration
    )
  end

  shared_examples_for 'bootstrap call' do
    it { should eql(expected_env) }
  end

  before do
    expect(integration_class).to receive(:new)
      .with(config.expression_parser)
      .and_return(integration)

    expect(integration).to receive(:setup).and_return(integration)

    expect(ObjectSpace).to receive(:each_object)
      .with(Module)
      .and_return(object_space_modules.each)
  end

  describe '#warn' do
    let(:object)  { described_class.new(config) }
    let(:message) { instance_double(String)     }

    subject { object.warn(message) }

    it 'reports a warning' do
      expect { subject }
        .to change { object.config.reporter.warn_calls }
        .from([])
        .to([message])
    end

    it_behaves_like 'a command method'
  end

  describe '.call' do
    subject { described_class.call(config) }

    context 'when Module#name calls result in exceptions' do
      let(:object_space_modules) { [invalid_class] }

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
          def name
          end
        end
      end

      it 'warns via reporter' do
        expected_warnings = [
          "Class#name from: #{invalid_class} raised an error: " \
          "RuntimeError. #{Mutant::Env::SEMANTICS_MESSAGE}"
        ]

        expect { subject }
          .to change { config.reporter.warn_calls }
          .from([])
          .to(expected_warnings)
      end

      include_examples 'bootstrap call'
    end

    context 'when requires are configured' do
      let(:config) { super().with(requires: %w[foo bar]) }

      before do
        %w[foo bar].each do |component|
          expect(Kernel).to receive(:require)
            .with(component)
            .and_return(true)
        end
      end

      include_examples 'bootstrap call'
    end

    context 'when includes are configured' do
      let(:config) { super().with(includes: %w[foo bar]) }

      before do
        %w[foo bar].each do |component|
          expect($LOAD_PATH).to receive(:<<)
            .with(component)
            .and_return($LOAD_PATH)
        end
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

      after do
        # Fix Class#name so other specs do not see this one
        class << invalid_class
          undef :name
          def name
          end
        end
      end

      it 'warns via reporter' do
        expected_warnings = [
          "Class#name from: #{invalid_class.inspect} returned Object. #{Mutant::Env::SEMANTICS_MESSAGE}"
        ]

        expect { subject }
          .to change { config.reporter.warn_calls }
          .from([]).to(expected_warnings)
      end

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
          subjects:         subjects,
          mutations:        subjects.flat_map(&:mutations)
        )
      end

      include_examples 'bootstrap call'
    end
  end
end
