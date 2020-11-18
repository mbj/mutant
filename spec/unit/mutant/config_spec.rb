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
      Mutant::Config::DEFAULT.with(**{ key => original_value })
    end

    let(:other) do
      Mutant::Config::DEFAULT.with(**{ key => other_value })
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

    shared_examples 'maybe value' do
      context 'when original has value' do
        context 'when other does not have value' do
          let(:other_value) { nil }

          it 'sets value to original value' do
            expect_value(original_value)
          end
        end

        context 'when other does have a value' do
          it 'sets value to other value' do
            expect_value(other_value)
          end
        end
      end

      context 'when original does not have value' do
        let(:original_value) { nil }

        context 'when other does not have value' do
          let(:other_value) { nil }

          it 'sets value to nil value' do
            expect_value(nil)
          end
        end

        context 'when other does have a value' do
          it 'sets value to other value' do
            expect_value(other_value)
          end
        end
      end
    end

    context 'merging jobs' do
      let(:key)            { :jobs }
      let(:original_value) { 2     }
      let(:other_value)    { 3     }

      include_examples 'maybe value'
    end

    context 'merging integration' do
      let(:key)            { :integration }
      let(:original_value) { 'rspec'      }
      let(:other_value)    { 'minitest'   }

      include_examples 'maybe value'
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

    context 'merging mutation timeout' do
      let(:key)            { :mutation_timeout }
      let(:original_value) { 1.0               }
      let(:other_value)    { 2.0               }

      include_examples 'maybe value'
    end

    context 'merging zombie' do
      let(:key) { :zombie }

      include_examples 'sticky boolean'
    end

    context 'merging fail fast' do
      let(:key) { :fail_fast }

      include_examples 'sticky boolean'
    end

    context 'merging includes' do
      let(:key) { :includes }

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

      before do
        allow(original_value).to receive_messages(merge: result_value)
      end

      it 'returns result value' do
        expect(apply.public_send(:matcher)).to be(result_value)
      end

      it 'merges matchers' do
        apply

        expect(original_value).to have_received(:merge).with(other_value)
      end
    end
  end

  describe '.env' do
    def apply
      described_class.env
    end

    let(:nprocessors) { instance_double(Integer, :nprocessors) }

    before do
      allow(Etc).to receive_messages(nprocessors: nprocessors)
    end

    it 'returns expected env derived config' do
      expect(apply).to eql(described_class::DEFAULT.with(jobs: nprocessors))
    end
  end

  describe '.load_config_file' do
    def apply
      described_class.load_config_file(world)
    end

    let(:config) { Mutant::Config::DEFAULT                            }
    let(:world)  { instance_double(Mutant::World, pathname: pathname) }

    let(:pathname) do
      paths = paths()
      Class.new do
        define_singleton_method(:new, &paths.method(:fetch))
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
      allow(Pathname).to receive(:new, &paths.method(:fetch))
    end

    context 'when no path is readable' do
      it 'returns original config' do
        expect(apply).to eql(Mutant::Either::Right.new(config))
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
          integration: rspec
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
            expect(apply)
              .to eql(Mutant::Either::Right.new(config.with(integration: 'rspec')))
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
            'mutant.yml/Mutant::Transform::Sequence/2/Mutant::Transform::Hash/["integration"]/String: Expected: String but got: TrueClass'
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
    end
  end
end
