RSpec.describe Mutant::CLI do
  let(:object) { described_class }

  shared_examples_for 'an invalid cli run' do
    it 'raises error' do
      expect do
        subject
      end.to raise_error(Mutant::CLI::Error, expected_message)
    end
  end

  shared_examples_for 'a cli parser' do
    it { expect(subject.config.integration).to eql(expected_integration) }
    it { expect(subject.config.reporter).to eql(expected_reporter)       }
    it { expect(subject.config.matcher).to eql(expected_matcher_config)  }
  end

  describe '.run' do
    subject { object.run(arguments) }

    let(:arguments) { double('arguments')                        }
    let(:report)    { double('Report', success?: report_success) }
    let(:config)    { double('Config')                           }
    let(:env)       { double('env')                              }

    before do
      expect(Mutant::CLI).to receive(:call).with(arguments).and_return(config)
      expect(Mutant::Env::Bootstrap).to receive(:call).with(config).and_return(env)
      expect(Mutant::Runner).to receive(:call).with(env).and_return(report)
    end

    context 'when report signals success' do
      let(:report_success) { true }

      it 'exits failure' do
        expect(subject).to be(0)
      end
    end

    context 'when report signals error' do
      let(:report_success) { false }

      it 'exits failure' do
        expect(subject).to be(1)
      end
    end

    context 'when execution raises an Mutant::CLI::Error' do
      let(:exception) { Mutant::CLI::Error.new('test-error') }
      let(:report_success) { nil }

      before do
        expect(report).to receive(:success?).and_raise(exception)
      end

      it 'exits failure' do
        expect($stderr).to receive(:puts).with('test-error')
        expect(subject).to be(1)
      end
    end
  end

  describe '.new' do
    let(:object) { described_class }

    subject { object.new(arguments) }

    # Defaults
    let(:expected_filter)         { Morpher.evaluator(s(:true))      }
    let(:expected_integration)    { 'null'                           }
    let(:expected_reporter)       { Mutant::Config::DEFAULT.reporter }
    let(:expected_matcher_config) { default_matcher_config           }

    let(:default_matcher_config) do
      Mutant::Matcher::Config::DEFAULT
        .with(match_expressions: expressions)
    end

    let(:flags)       { []           }
    let(:expressions) { %w[TestApp*] }

    let(:arguments) { flags + expressions }

    context 'with unknown flag' do
      let(:flags) { %w[--invalid] }

      let(:expected_message) { 'invalid option: --invalid' }

      it_should_behave_like 'an invalid cli run'
    end

    context 'with unknown option' do
      let(:flags) { %w[--invalid Foo] }

      let(:expected_message) { 'invalid option: --invalid' }

      it_should_behave_like 'an invalid cli run'
    end

    context 'without expressions' do
      let(:expressions) { [] }

      let(:expected_message) { 'No expressions given' }

      it_should_behave_like 'an invalid cli run'
    end

    context 'with include help flag' do
      let(:flags) { %w[--help] }

      before do
        expect($stdout).to receive(:puts).with(expected_message)
        expect(Kernel).to receive(:exit).with(0)
      end

      it_should_behave_like 'a cli parser'

      let(:expected_message) do
        strip_indent(<<-MESSAGE)
usage: mutant [options] MATCH_EXPRESSION ...
Environment:
        --zombie                     Run mutant zombified
    -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
    -r, --require NAME               Require file with NAME
    -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.

Options:
        --expected-coverage COVERAGE Fail unless COVERAGE is not reached exactly, parsed via Rational()
        --use INTEGRATION            Use INTEGRATION to kill mutations
        --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
        --since REVISION             Only select subjects touched since REVISION
        --fail-fast                  Fail fast
        --version                    Print mutants version
    -d, --debug                      Enable debugging output
    -h, --help                       Show this message
        MESSAGE
      end
    end

    context 'with include flag' do
      let(:flags) { %w[--include foo] }

      it_should_behave_like 'a cli parser'

      it 'configures includes' do
        expect(subject.config.includes).to eql(%w[foo])
      end
    end

    context 'with use flag' do
      context 'when integration exists' do
        let(:flags) { %w[--use rspec] }

        it_should_behave_like 'a cli parser'

        let(:expected_integration) { 'rspec' }
      end

      context 'when does not' do
        let(:flags) { %w[--use foo] }

        let(:expected_message) { 'Could not load integration "foo" (install the gem mutant-foo if exists)' }

        it_should_behave_like 'an invalid cli run'
      end
    end

    context 'with version flag' do
      let(:flags) { %w[--version] }

      before do
        expect(Kernel).to receive(:exit).with(0)
        expect($stdout).to receive(:puts).with("mutant-#{Mutant::VERSION}")
      end

      it_should_behave_like 'a cli parser'
    end

    context 'with jobs flag' do
      let(:flags) { %w[--jobs 0] }

      it_should_behave_like 'a cli parser'

      it 'configures expected coverage' do
        expect(subject.config.jobs).to eql(0)
      end
    end

    context 'with expected-coverage flag' do
      context 'given as decimal' do
        let(:flags) { %w[--expected-coverage 0.1] }

        it_should_behave_like 'a cli parser'

        it 'configures expected coverage' do
          expect(subject.config.expected_coverage).to eql(Rational(1, 10))
        end
      end

      context 'given as scientific' do
        let(:flags) { %w[--expected-coverage 1e-1] }

        it_should_behave_like 'a cli parser'

        it 'configures expected coverage' do
          expect(subject.config.expected_coverage).to eql(Rational(1, 10))
        end
      end

      context 'given as rational' do
        let(:flags) { %w[--expected-coverage 1/10] }

        it_should_behave_like 'a cli parser'

        it 'configures expected coverage' do
          expect(subject.config.expected_coverage).to eql(Rational(1, 10))
        end
      end
    end

    context 'with require flags' do
      let(:flags) { %w[--require foo --require bar] }

      it_should_behave_like 'a cli parser'

      it 'configures requires' do
        expect(subject.config.requires).to eql(%w[foo bar])
      end
    end

    context 'with --since flag' do
      let(:flags) { %w[--since master] }

      let(:expected_matcher_config) do
        default_matcher_config.with(
          subject_filters: [
            Mutant::Repository::SubjectFilter.new(Mutant::Repository::Diff.new('HEAD', 'master'))
          ]
        )
      end

      it_should_behave_like 'a cli parser'
    end

    context 'with subject-ignore flag' do
      let(:flags) { %w[--ignore-subject Foo::Bar] }

      let(:expected_matcher_config) do
        default_matcher_config.with(ignore_expressions: %w[Foo::Bar])
      end

      it_should_behave_like 'a cli parser'
    end

    context 'with fail-fast flag' do
      let(:flags) { %w[--fail-fast] }

      it_should_behave_like 'a cli parser'

      it 'sets the fail fast option' do
        expect(subject.config.fail_fast).to be(true)
      end
    end

    context 'with debug flag' do
      let(:flags) { %w[--debug] }

      it_should_behave_like 'a cli parser'

      it 'sets the debug option' do
        expect(subject.config.debug).to be(true)
      end
    end

    context 'with zombie flag' do
      let(:flags)   { %w[--zombie] }

      it_should_behave_like 'a cli parser'

      it 'sets the zombie option' do
        expect(subject.config.zombie).to be(true)
      end
    end
  end
end
