# frozen_string_literal: true

RSpec.describe Mutant::CLI do
  let(:default_config) { Mutant::Config::DEFAULT                        }
  let(:kernel)         { instance_double('kernel', exit: undefined)     }
  let(:stderr)         { instance_double(IO, 'stderr', puts: undefined) }
  let(:stdout)         { instance_double(IO, 'stdout', puts: undefined) }
  let(:target_stream)  { stdout                                         }
  let(:undefined)      { instance_double('undefined')                   }

  let(:config) do
    attributes = Mutant::Config.anima.attribute_names.map do |name|
      [name, instance_double(Object, name)]
    end.to_h

    Mutant::Config.new(
      attributes.merge(
        expression_parser: default_config.expression_parser,
        fail_fast:         false,
        includes:          [],
        integration:       default_config.integration,
        kernel:            kernel,
        matcher:           default_config.matcher,
        requires:          [],
        stderr:            stderr,
        stdout:            stdout
      )
    )
  end

  shared_examples 'prints expected message' do

    it 'prints expected message' do
      apply

      expect(target_stream).to have_received(:puts).with(expected_message)
    end
  end

  before do
    allow(stderr).to receive_messages(puts: undefined)
    allow(stdout).to receive_messages(puts: undefined)
  end

  describe '.run' do
    def apply
      described_class.run(config, arguments)
    end

    let(:arguments)      { instance_double(Array)       }
    let(:env)            { instance_double(Mutant::Env) }
    let(:report_success) { true                         }

    let(:report) do
      instance_double(Mutant::Result::Env, success?: report_success)
    end

    before do
      allow(Mutant::CLI).to receive_messages(call: config)
      allow(Mutant::Env::Bootstrap).to receive_messages(call: env)
      allow(Mutant::Runner).to receive_messages(call: report)
    end

    it 'performs calls in expected sequence' do
      apply

      expect(Mutant::CLI).to have_received(:call).with(config, arguments).ordered
      expect(Mutant::Env::Bootstrap).to have_received(:call).with(config).ordered
      expect(Mutant::Runner).to have_received(:call).with(env).ordered
    end

    context 'when report signals success' do
      let(:report_success) { true }

      it 'exits failure' do
        expect(apply).to be(true)
      end
    end

    context 'when report signals error' do
      let(:report_success) { false }

      it 'exits failure' do
        expect(apply).to be(false)
      end
    end

    context 'when execution raises an Mutant::CLI::Error' do
      let(:exception)        { Mutant::CLI::Error.new('test-error') }
      let(:expected_message) { 'test-error'                         }
      let(:report_success)   { false                                }
      let(:target_stream)    { stderr                               }

      before do
        allow(report).to receive(:success?).and_raise(exception)
      end

      it 'exits with failure' do
        expect(apply).to be(false)
      end

      include_examples 'prints expected message'
    end
  end

  describe '.new' do
    shared_examples 'invalid arguments' do
      it 'raises error' do
        expect do
          apply
        end.to raise_error(Mutant::CLI::Error, expected_message)
      end
    end

    shared_examples 'explicit exit' do
      it 'prints explicitly exits' do
        apply

        expect(kernel).to have_received(:exit)
      end
    end

    shared_examples 'no explicit exit' do
      it 'does not exit' do
        expect(kernel).to_not have_received(:exit)
      end
    end

    shared_examples_for 'cli parser' do
      it { expect(apply.config.integration).to eql(expected_integration) }
      it { expect(apply.config.matcher).to eql(expected_matcher_config)  }
    end

    def apply
      described_class.new(config, arguments)
    end

    before do
      allow(kernel).to receive_messages(exit: nil)
    end

    let(:arguments)               { options + expressions     }
    let(:expected_integration)    { Mutant::Integration::Null }
    let(:expected_matcher_config) { default_matcher_config    }
    let(:expressions)             { %w[TestApp*]              }
    let(:options)                 { []                        }

    let(:default_matcher_config) do
      Mutant::Matcher::Config::DEFAULT
        .with(match_expressions: expressions.map(&method(:parse_expression)))
    end

    context 'with --invalid option' do
      let(:options)          { %w[--invalid]               }
      let(:expected_message) { 'invalid option: --invalid' }

      include_examples 'invalid arguments'
      include_examples 'no explicit exit'
    end

    context 'with --help option' do
      let(:options) { %w[--help] }

      let(:expected_message) do
        <<~MESSAGE
          usage: mutant [options] MATCH_EXPRESSION ...
          Environment:
                  --zombie                     Run mutant zombified
              -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
              -r, --require NAME               Require file with NAME
              -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.

          Options:
                  --use INTEGRATION            Use INTEGRATION to kill mutations
                  --ignore-subject EXPRESSION  Ignore subjects that match EXPRESSION as prefix
                  --since REVISION             Only select subjects touched since REVISION
                  --fail-fast                  Fail fast
                  --version                    Print mutants version
              -h, --help                       Show this message
        MESSAGE
      end

      include_examples 'cli parser'
      include_examples 'explicit exit'
      include_examples 'prints expected message'
    end

    context 'with --include option' do
      let(:options) { %w[--include foo] }

      include_examples 'cli parser'
      include_examples 'no explicit exit'

      it 'configures includes' do
        expect(apply.config.includes).to eql(%w[foo])
      end
    end

    context 'with --use option' do
      context 'when integration exists' do
        let(:expected_integration) { integration                          }
        let(:options)              { %w[--use rspec]                      }
        let(:integration)          { instance_double(Mutant::Integration) }

        before do
          allow(Mutant::Integration).to receive_messages(setup: integration)
        end

        include_examples 'cli parser'
        include_examples 'no explicit exit'

        it 'does integration setup' do
          apply

          expect(Mutant::Integration).to have_received(:setup) do |kernel_arg, name|
            expect(kernel_arg).to be(kernel)
            expect(name).to eql('rspec')
          end
        end
      end

      context 'when integration does NOT exist' do
        let(:options) { %w[--use other] }

        before do
          allow(Mutant::Integration).to receive(:setup).and_raise(LoadError)
        end

        it 'raises error' do
          expect { apply }.to raise_error(
            Mutant::CLI::Error,
            'Could not load integration "other" (you may want to try installing the gem mutant-other)'
          )
        end
      end
    end

    context 'with --version option' do
      let(:expected_message) { "mutant-#{Mutant::VERSION}" }
      let(:options)          { %w[--version]               }

      include_examples 'cli parser'
      include_examples 'explicit exit'
      include_examples 'prints expected message'
    end

    context 'with --jobs option' do
      let(:options) { %w[--jobs 0] }

      include_examples 'cli parser'
      include_examples 'no explicit exit'

      it 'configures expected coverage' do
        expect(apply.config.jobs).to eql(0)
      end
    end

    context 'with --require options' do
      let(:options) { %w[--require foo --require bar] }

      include_examples 'cli parser'
      include_examples 'no explicit exit'

      it 'configures requires' do
        expect(apply.config.requires).to eql(%w[foo bar])
      end
    end

    context 'with --since option' do
      let(:options) { %w[--since master] }

      let(:expected_matcher_config) do
        default_matcher_config.with(
          subject_filters: [
            Mutant::Repository::SubjectFilter.new(
              Mutant::Repository::Diff.new(
                config: config,
                from:   'HEAD',
                to:     'master'
              )
            )
          ]
        )
      end

      include_examples 'cli parser'
      include_examples 'no explicit exit'
    end

    context 'with --subject-ignore option' do
      let(:options) { %w[--ignore-subject Foo::Bar] }

      let(:expected_matcher_config) do
        default_matcher_config.with(ignore_expressions: [parse_expression('Foo::Bar')])
      end

      include_examples 'cli parser'
      include_examples 'no explicit exit'
    end

    context 'with --fail-fast option' do
      let(:options) { %w[--fail-fast] }

      include_examples 'cli parser'
      include_examples 'no explicit exit'

      it 'sets the fail fast option' do
        expect(apply.config.fail_fast).to be(true)
      end
    end

    context 'with --zombie option' do
      let(:options) { %w[--zombie] }

      include_examples 'cli parser'
      include_examples 'no explicit exit'

      it 'sets the zombie option' do
        expect(apply.config.zombie).to be(true)
      end
    end
  end
end
