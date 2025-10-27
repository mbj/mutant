# frozen_string_literal: true

RSpec.describe Mutant::CLI::Command::MCP::Info do
  let(:stdout_output) { StringIO.new }
  let(:stdout) { stdout_output }

  let(:world) { instance_double(Mutant::World, stdout:, json: JSON) }

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
    it 'returns Right with nil' do
      result = command.action
      expect(result).to be_instance_of(Mutant::Either::Right)
      expect(result.from_right).to be_nil
    end

    it 'outputs server information' do
      command.action

      expected_output = <<~OUTPUT
        Server: mutant
        Version: #{Mutant::VERSION}

        Capabilities:
          Resources: 2
          Tools: 0 (Phase 3)
          Prompts: 0 (Phase 4)

        Status: Phase 2 - Resources Complete

        Available Resources:
          - mutant://version: Mutant Version
          - mutant://config: Mutant Configuration

        To start the server:
          mutant mcp server [options]
      OUTPUT

      expect(stdout_output.string).to eql(expected_output)
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
end
