RSpec.describe Mutant::Env::Bootstrap do
  let(:config) do
    Mutant::Config::DEFAULT.update(
      jobs:     1,
      reporter: Mutant::Reporter::Trace.new,
      includes: [],
      requires: [],
      matcher_config: Mutant::Matcher::Config::DEFAULT
    )
  end

  let(:expected_env) do
    Mutant::Env.new(
      cache:            Mutant::Cache.new,
      subjects:         [],
      matchable_scopes: [],
      mutations:        [],
      config:           config,
      selector:         Mutant::Selector::Expression.new(config.integration.all_tests),
      actor_env:        Mutant::Actor::Env.new(Thread)
    )
  end

  shared_examples_for 'bootstrap call' do
    it { should eql(expected_env) }
  end

  let(:object_space_modules) { [] }

  before do
    allow(ObjectSpace).to receive(:each_object).with(Module).and_return(object_space_modules.each)
  end

  describe '.call' do
    subject { described_class.call(config) }

    context 'when Module#name calls result in exceptions' do
      let(:invalid_class) do
        Class.new do
          def self.name
            fail
          end
        end
      end

      let(:object_space_modules) { [invalid_class] }

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
          "Class#name from: #{invalid_class} raised an error: RuntimeError. #{Mutant::Env::SEMANTICS_MESSAGE}"
        ]

        expect { subject }.to change { config.reporter.warn_calls }.from([]).to(expected_warnings)
      end

      include_examples 'bootstrap call'
    end

    context 'when includes are present' do
      let(:config) { super().update(includes: %w[foo bar]) }

      before do
        %w[foo bar].each do |component|
          expect($LOAD_PATH).to receive(:<<).with(component).and_return($LOAD_PATH)
        end
      end

      include_examples 'bootstrap call'
    end

    context 'when Module#name does not return a String or nil' do
      let(:invalid_class) do
        Class.new do
          def self.name
            Object
          end
        end
      end

      let(:object_space_modules) { [invalid_class] }

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

        expect { subject }.to change { config.reporter.warn_calls }.from([]).to(expected_warnings)
      end

      include_examples 'bootstrap call'
    end

    context 'when scope matches expression' do
      let(:mutations) { [double('Mutation')]                      }
      let(:subjects)  { [double('Subject', mutations: mutations)] }

      before do
        expect(Mutant::Matcher::Compiler).to receive(:call).and_return(subjects)
      end

      let(:expected_env) do
        super().update(
          subjects:  subjects,
          mutations: mutations
        )
      end

      include_examples 'bootstrap call'
    end
  end
end
