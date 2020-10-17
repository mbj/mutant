# frozen_string_literal: true

RSpec.describe Mutant::Config do
  describe '.load_config_file' do
    def apply
      described_class.load_config_file(world, config)
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
