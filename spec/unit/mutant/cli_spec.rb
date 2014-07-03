require 'spec_helper'

shared_examples_for 'an invalid cli run' do
  it 'raises error' do
    expect do
      subject
    end.to raise_error(Mutant::CLI::Error, expected_message)
  end
end

shared_examples_for 'a cli parser' do
  it { expect(subject.config.integration).to eql(expected_integration)       }
  it { expect(subject.config.reporter).to eql(expected_reporter)             }
  it { expect(subject.config.matcher_config).to eql(expected_matcher_config) }
end

describe Mutant::CLI do
  describe '.new' do
    let(:object) { described_class }

    subject { object.new(arguments) }

    # Defaults
    let(:expected_filter)         { Morpher.evaluator(s(:true))        }
    let(:expected_integration)    { Mutant::Integration::Null.new      }
    let(:expected_reporter)       { Mutant::Reporter::CLI.new($stdout) }
    let(:expected_matcher_config) { default_matcher_config             }

    let(:default_matcher_config) do
      Mutant::Matcher::Config::DEFAULT
        .update(match_expressions: expressions.map(&Mutant::Expression.method(:parse)))
    end

    let(:ns)    { Mutant::Matcher    }

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

    context 'with code filter and missing argument' do
      let(:arguments)        { %w[--code]                 }
      let(:expected_message) { 'missing argument: --code' }

      it_should_behave_like 'an invalid cli run'
    end

    context 'with include flag' do
      let(:flags) { %w[--include foo] }

      it_should_behave_like 'a cli parser'

      it 'configures includes' do
        expect(subject.config.includes).to eql(%w[foo])
      end
    end

    context 'with require flag' do
      let(:flags) { %w[--require foo] }

      it_should_behave_like 'a cli parser'

      it 'configures requires' do
        expect(subject.config.requires).to eql(%w[foo])
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

    context 'with subject code filter' do
      let(:flags) { %w[--code faa --code bbb] }

      let(:expected_matcher_config) do
        default_matcher_config.update(subject_selects: [[:code, 'faa'], [:code, 'bbb']])
      end

      it_should_behave_like 'a cli parser'
    end
  end
end
