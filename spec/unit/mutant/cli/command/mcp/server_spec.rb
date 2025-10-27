# frozen_string_literal: true

RSpec.describe Mutant::CLI::Command::MCP::Server do
  let(:world) { instance_double(Mutant::World) }

  let(:expected_cli_config) do
    Mutant::Config::DEFAULT.with(
      coverage_criteria: Mutant::Config::CoverageCriteria::EMPTY
    )
  end

  let(:command) do
    described_class.new(
      main:          nil,
      parent_names:  %w[mutant mcp],
      print_profile: false,
      world:,
      zombie:        false
    )
  end

  describe '#action' do
    context 'when server runs successfully' do
      before do
        allow(Mutant::MCP::Server).to receive(:run).and_return(Mutant::Either::Right.new(nil))
      end

      it 'returns Right with nil' do
        result = command.action
        expect(result).to be_instance_of(Mutant::Either::Right)
        expect(result.from_right).to be_nil
      end

      it 'calls MCP::Server.run with correct config and world' do
        command.action
        expect(Mutant::MCP::Server).to have_received(:run).with(
          cli_config: expected_cli_config,
          world:
        )
      end
    end

    context 'when server returns error' do
      before do
        allow(Mutant::MCP::Server).to receive(:run).and_return(Mutant::Either::Left.new('Server failed'))
      end

      it 'returns Left with error message' do
        result = command.action
        expect(result).to be_instance_of(Mutant::Either::Left)
        expect(result.from_left).to eql('Server failed')
      end
    end
  end

  describe '#parse_remaining_arguments' do
    context 'with no arguments' do
      it 'returns Right with self' do
        result = command.send(:parse_remaining_arguments, [])
        expect(result).to be_instance_of(Mutant::Either::Right)
        expect(result.from_right).to be(command)
      end
    end

    context 'with unexpected arguments' do
      it 'returns Left with error message' do
        result = command.send(:parse_remaining_arguments, %w[extra args])
        expect(result).to be_instance_of(Mutant::Either::Left)
        expect(result.from_left).to eql('Unexpected arguments: extra args')
      end
    end
  end

  describe '.NAME' do
    it 'returns server' do
      expect(described_class::NAME).to eql('server')
    end
  end

  describe '.SHORT_DESCRIPTION' do
    it 'returns description' do
      expect(described_class::SHORT_DESCRIPTION).to eql('Run MCP server over STDIO')
    end
  end
end
