# frozen_string_literal: true

RSpec.describe Mutant::Config do
  describe '#merge' do
    def apply
      original.merge(other)
    end

    def expect_value(value)
      expect(apply).to eql(original.with(key => value))
    end

    let(:original) do
      Mutant::Config::DEFAULT.with(key => original_value)
    end

    let(:other) do
      Mutant::Config::DEFAULT.with(key => other_value)
    end

    shared_examples 'overwrite value' do
      it 'sets value to other value' do
        expect(apply.public_send(key)).to be(other_value)
      end
    end

    shared_examples 'array concat' do
      let(:other_value)    { %w[foo] }
      let(:original_value) { %w[bar] }

      it 'adds other and orignial' do
        expect_value(original_value + other_value)
      end
    end

    shared_examples 'descendant merge' do
      before do
        allow(original_value).to receive_messages(merge: result_value)
      end

      it 'returns descendant result value' do
        expect(apply.public_send(key)).to be(result_value)
      end

      it 'merges descendants' do
        apply

        expect(original_value).to have_received(:merge).with(other_value)
      end
    end

    shared_examples 'sticky boolean' do
      context 'when original is false' do
        let(:original_value) { false }

        context 'when other value is false' do
          let(:other_value) { false }

          it 'sets value to false' do
            expect_value(false)
          end
        end

        context 'when other value is true' do
          let(:other_value) { true }

          it 'sets value to true' do
            expect_value(true)
          end
        end
      end

      context 'when original is true' do
        let(:original_value) { true }

        context 'when other value is false' do
          let(:other_value) { false }

          it 'sets value to false' do
            expect_value(true)
          end
        end

        context 'when other value is true' do
          let(:other_value) { true }

          it 'sets value to true' do
            expect_value(true)
          end
        end
      end
    end

    context 'merging jobs' do
      let(:key)            { :jobs }
      let(:original_value) { 2     }
      let(:other_value)    { 3     }

      include_examples 'maybe value merge'
    end

    context 'merging environment variables' do
      let(:key)            { :environment_variables                         }
      let(:original_value) { { 'KEY_A' => 'VALUE_A', 'KEY_B' => 'VALUE_B' } }
      let(:other_value)    { { 'KEY_A' => 'VALUE_X', 'KEY_C' => 'VALUE_C' } }

      it 'merges with preference for other' do
        expect_value(
          'KEY_A' => 'VALUE_X',
          'KEY_B' => 'VALUE_B',
          'KEY_C' => 'VALUE_C'
        )
      end
    end

    context 'merging integration' do
      let(:key) { :integration }

      let(:original_value) do
        instance_double(Mutant::Integration::Config, 'original')
      end

      let(:other_value) do
        instance_double(Mutant::Integration::Config, 'other')
      end

      let(:result_value) do
        instance_double(Mutant::Integration::Config, 'result')
      end

      include_examples 'descendant merge'
    end

    context 'merging expression_parser' do
      let(:key) { :expression_parser }

      let(:original_value) do
        instance_double(Mutant::Expression::Parser, 'config')
      end

      let(:other_value) do
        instance_double(Mutant::Expression::Parser, 'other')
      end

      include_examples 'overwrite value'
    end

    context 'merging isolation' do
      let(:key)            { :isolation                                   }
      let(:original_value) { instance_double(Mutant::Isolation, 'config') }
      let(:other_value)    { instance_double(Mutant::Isolation, 'other')  }

      include_examples 'overwrite value'
    end

    context 'merging reporter' do
      let(:key)            { :isolation                                  }
      let(:original_value) { instance_double(Mutant::Reporter, 'config') }
      let(:other_value)    { instance_double(Mutant::Reporter, 'other')  }

      include_examples 'overwrite value'
    end

    context 'merging mutation config' do
      let(:key)            { :mutation                                            }
      let(:original_value) { Mutant::Mutation::Config::DEFAULT.with(timeout: 1.0) }
      let(:other_value)    { Mutant::Mutation::Config::DEFAULT.with(timeout: 2.0) }
      let(:result_value)   { Mutant::Mutation::Config::DEFAULT.with(timeout: 2.0) }

      include_examples 'descendant merge'
    end

    context 'merging fail fast' do
      let(:key) { :fail_fast }

      include_examples 'sticky boolean'
    end

    context 'merging includes' do
      let(:key) { :includes }

      include_examples 'array concat'
    end

    context 'merging hooks' do
      let(:key) { :hooks }

      include_examples 'array concat'
    end

    context 'merging requires' do
      let(:key) { :requires }

      include_examples 'array concat'
    end

    context 'merging matcher' do
      let(:key)            { :matcher                                            }
      let(:original_value) { instance_double(Mutant::Matcher::Config, :original) }
      let(:other_value)    { instance_double(Mutant::Matcher::Config, :other)    }
      let(:result_value)   { instance_double(Mutant::Matcher::Config, :result)   }

      include_examples 'descendant merge'
    end

    context 'merging coverage criteria' do
      let(:key) { :coverage_criteria }

      let(:original_value) do
        instance_double(Mutant::Config::CoverageCriteria, 'config')
      end

      let(:other_value) do
        instance_double(Mutant::Config::CoverageCriteria, 'other')
      end

      let(:result_value) do
        instance_double(Mutant::Config::CoverageCriteria, 'result')
      end

      include_examples 'descendant merge'
    end
  end

  describe '.load' do
    def apply
      described_class.load(cli_config: cli_config, world: world)
    end

    let(:cli_config)  { Mutant::Config::DEFAULT                            }
    let(:nprocessors) { instance_double(Integer, :nprocessors)             }
    let(:world)       { instance_double(Mutant::World, pathname: pathname) }

    let(:pathname) do
      paths = paths()
      Class.new do
        define_singleton_method(:new, &paths.public_method(:fetch))
      end
    end

    let(:config_mutant_yml) do
      instance_double(Pathname, 'config/mutant.yml', readable?: false)
    end

    let(:dot_mutant_yml) do
      instance_double(Pathname, '.mutant.yml', readable?: false)
    end

    let(:mutant_yml) do
      instance_double(Pathname, 'mutant.yml', readable?: false)
    end

    let(:paths) do
      {
        '.mutant.yml'       => dot_mutant_yml,
        'config/mutant.yml' => config_mutant_yml,
        'mutant.yml'        => mutant_yml
      }
    end

    before do
      allow(Pathname).to receive(:new, &paths.public_method(:fetch))
      allow(Etc).to receive_messages(nprocessors: nprocessors)
    end

    context 'when no path is readable' do
      it 'returns original config' do
        expect(apply).to eql(Mutant::Either::Right.new(cli_config.with(jobs: nprocessors)))
      end
    end

    context 'when more than one path is readable' do
      before do
        [config_mutant_yml, mutant_yml].each do |path|
          allow(path).to receive_messages(readable?: true)
        end
      end

      let(:expected_message) do
        <<~MESSAGE
          Found more than one candidate for use as implicit config file: #{config_mutant_yml}, #{mutant_yml}
        MESSAGE
      end

      it 'returns expected failure' do
        expect(apply).to eql(Mutant::Either::Left.new(expected_message))
      end
    end

    context 'with one readable path' do
      let(:path_contents) do
        <<~'YAML'
          ---
          integration:
            name: rspec
        YAML
      end

      before do
        allow(mutant_yml).to receive_messages(
          read:      path_contents,
          readable?: true,
          to_s:      'mutant.yml'
        )
      end

      context 'when file can be read' do
        context 'when yaml contents can be transformed' do
          it 'returns expected config' do
            expect(apply).to eql(
              Mutant::Either::Right.new(
                cli_config.with(
                  integration: Mutant::Integration::Config::DEFAULT.with(name: 'rspec'),
                  jobs:        nprocessors
                )
              )
            )
          end
        end

        context 'when yaml is invalid' do
          let(:path_contents) do
            <<~'YAML'
              ---
              : true
            YAML
          end

          # rubocop:disable Layout/LineLength
          let(:expected_message) do
            'mutant.yml/Mutant::Transform::Sequence/1/Mutant::Transform::Exception: (<unknown>): did not find expected key while parsing a block mapping at line 2 column 1'
          end
          # rubocop:enable Layout/LineLength

          it 'returns expected error' do
            expect(apply).to eql(Mutant::Either::Left.new(expected_message))
          end
        end

        context 'when yaml contents cannot be transformed' do
          let(:path_contents) do
            <<~'YAML'
              ---
              integration: true
            YAML
          end

          # rubocop:disable Layout/LineLength
          let(:expected_message) do
            'mutant.yml/Mutant::Transform::Sequence/4/Mutant::Transform::Hash/["integration"]/Mutant::Transform::Sequence/0/Hash: Expected: Hash but got: TrueClass'
          end
          # rubocop:enable Layout/LineLength

          it 'returns expected error' do
            expect(apply).to eql(Mutant::Either::Left.new(expected_message))
          end
        end
      end

      context 'when file cannot be read' do
        before do
          allow(mutant_yml).to receive(:read).and_raise(SystemCallError, 'some error')
        end

        let(:expected_message) do
          'mutant.yml/Mutant::Transform::Sequence/0/Mutant::Transform::Exception: unknown error - some error'
        end

        it 'returns expected error' do
          expect(apply).to eql(Mutant::Either::Left.new(expected_message))
        end
      end

      context 'deprecated integration toplevel string key' do
        let(:path_contents) do
          <<~'YAML'
            ---
            integration: rspec
          YAML
        end

        before do
          allow(cli_config.reporter).to receive_messages(warn: cli_config.reporter)
        end

        it 'renders expected warning' do
          apply

          expect(cli_config.reporter).to have_received(:warn).with(<<~'MESSAGE')
            Deprecated configuration toplevel string key `integration` found.

            This key will be removed in the next major version.
            Instead place your integration configuration under the `integration.name` key
            like this:

            ```
            # mutant.yml
            integration:
              name: your_integration # typically rspec or minitest
            ```
          MESSAGE
        end

        it 'returns expected config' do
          expect(apply.from_right.integration).to eql(Mutant::Integration::Config::DEFAULT.with(name: 'rspec'))
        end
      end

      context 'deprecated mutation_timeout toplevel key' do
        let(:path_contents) do
          <<~'YAML'
            ---
            mutation_timeout: 10.0
          YAML
        end

        before do
          allow(cli_config.reporter).to receive_messages(warn: cli_config.reporter)
        end

        it 'renders expected warning' do
          apply

          expect(cli_config.reporter).to have_received(:warn).with(<<~'MESSAGE')
            Deprecated configuration toplevel key `mutation_timeout` found.

            This key will be removed in the next major version.
            Instead place your mutation timeout configuration under the `mutation` key
            like this:

            ```
            # mutant.yml
            mutation:
              timeout: 10.0 # float here.
            ```
          MESSAGE
        end

        context 'when cli does not overwrite' do
          it 'returns expected config' do
            expect(apply.from_right.mutation).to eql(
              Mutant::Config::DEFAULT.with(
                mutation: Mutant::Mutation::Config::DEFAULT.with(timeout: 10.0)
              ).mutation
            )
          end
        end

        context 'when cli does not overwrites' do
          let(:cli_config) { super().with(mutation: super().mutation.with(timeout: 1.0)) }

          it 'returns expected config' do
            expect(apply.from_right.mutation).to eql(
              Mutant::Config::DEFAULT.with(
                mutation: Mutant::Mutation::Config::DEFAULT.with(timeout: 1.0)
              ).mutation
            )
          end
        end
      end
    end
  end

  describe '.parse_environment_variables' do
    def apply
      described_class.parse_environment_variables(input)
    end

    context 'on non string keys' do
      let(:input) { { 1 => 'foo' } }

      it 'returns expected value' do
        expect(apply).to eql(left('Non string keys: [1]'))
      end
    end

    context 'on malformed string keys' do
      let(:input) { { 'foo=' => 'foo' } }

      it 'returns expected value' do
        expect(apply).to eql(left('Invalid keys: ["foo="]'))
      end
    end

    context 'non string values' do
      let(:input) { { 'foo' => 1 } }

      it 'returns expected value' do
        expect(apply).to eql(left('Non string values: [1]'))
      end
    end

    context 'valid input' do
      let(:input) { { 'foo' => 'bar' } }

      it 'returns expected value' do
        expect(apply).to eql(right('foo' => 'bar'))
      end
    end
  end
end
