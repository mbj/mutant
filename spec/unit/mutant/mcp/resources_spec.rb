# frozen_string_literal: true

RSpec.describe Mutant::MCP::Resources do
  let(:cli_config) { Mutant::Config::DEFAULT }

  let(:world) do
    instance_double(
      Mutant::World,
      json: JSON
    )
  end

  describe '.build' do
    it 'returns version and config resources' do
      resources = described_class.build

      expect(resources).to match(
        [
          have_attributes(
            uri:         'mutant://version',
            name:        'Mutant Version',
            description: 'Mutant version and Ruby environment information',
            mime_type:   'application/json'
          ),
          have_attributes(
            uri:         'mutant://config',
            name:        'Mutant Configuration',
            description: 'Loaded mutant configuration (file + env)',
            mime_type:   'application/json'
          )
        ]
      )
    end
  end

  describe '.read' do
    context 'when reading version resource' do
      it 'returns version information as JSON' do
        contents = described_class.read(uri: 'mutant://version', cli_config:, world:)

        expect(contents).to match(
          [
            have_attributes(
              uri:       'mutant://version',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(
                'version'      => Mutant::VERSION,
                'ruby_version' => RUBY_VERSION,
                'platform'     => RUBY_PLATFORM
              )
            )
          ]
        )
      end
    end

    context 'when reading config resource' do
      let(:config_double) do
        instance_double(
          Mutant::Config,
          to_h: {
            integration: { name: 'rspec' },
            jobs:        4,
            includes:    ['lib']
          }
        )
      end

      before do
        allow(Mutant::Config).to receive(:load)
          .with(cli_config:, world:)
          .and_return(Mutant::Either::Right.new(config_double))
      end

      it 'returns loaded config as JSON' do
        contents = described_class.read(uri: 'mutant://config', cli_config:, world:)

        expect(contents).to match(
          [
            have_attributes(
              uri:       'mutant://config',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(
                integration: { name: 'rspec' },
                jobs:        4,
                includes:    ['lib']
              )
            )
          ]
        )
      end
    end

    context 'when reading config resource fails' do
      before do
        allow(Mutant::Config).to receive(:load)
          .with(cli_config:, world:)
          .and_return(Mutant::Either::Left.new('Config load error'))
      end

      it 'returns error in JSON' do
        contents = described_class.read(uri: 'mutant://config', cli_config:, world:)

        expect(contents).to match(
          [
            have_attributes(
              uri:       'mutant://config',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(error: 'Config load error')
            )
          ]
        )
      end
    end

    context 'when reading unknown resource' do
      it 'returns empty array' do
        contents = described_class.read(uri: 'mutant://unknown', cli_config:, world:)

        expect(contents).to eql([])
      end
    end
  end
end
