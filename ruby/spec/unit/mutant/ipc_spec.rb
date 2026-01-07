# frozen_string_literal: true

RSpec.describe Mutant::IPC do
  let(:socket_path) { '/tmp/test.sock' }
  let(:json)        { class_double(JSON) }
  let(:unix_socket) { class_double(UNIXSocket) }
  let(:world)       { instance_double(Mutant::World, json:, unix_socket:) }
  let(:socket)      { instance_double(UNIXSocket) }

  let(:object) do
    described_class.new(socket_path:, world:)
  end

  describe '#call' do
    def apply
      object.call
    end

    let(:ping_payload)       { 'test-payload-uuid' }
    let(:ping_body)          { '{"type":"ping","payload":"test-payload-uuid"}' }
    let(:ping_response_body) { '"test-payload-uuid"' }
    let(:exit_body)          { '{"type":"exit"}' }
    let(:exit_response_body) { 'null' }

    let(:create_socket) do
      [
        {
          receiver:  unix_socket,
          selector:  :new,
          arguments: [socket_path],
          reaction:  { return: socket }
        }
      ]
    end

    let(:close_socket) do
      [
        {
          receiver: socket,
          selector: :close
        }
      ]
    end

    let(:read_ping) do
      [
        {
          receiver:  socket,
          selector:  :read,
          arguments: [4],
          reaction:  { return: [ping_body.bytesize].pack('V') }
        },
        {
          receiver:  socket,
          selector:  :read,
          arguments: [ping_body.bytesize],
          reaction:  { return: ping_body }
        },
        {
          receiver:  json,
          selector:  :parse,
          arguments: [ping_body],
          reaction:  { return: { 'type' => 'ping', 'payload' => ping_payload } }
        }
      ]
    end

    let(:write_ping_response) do
      [
        {
          receiver:  json,
          selector:  :generate,
          arguments: [ping_payload],
          reaction:  { return: ping_response_body }
        },
        {
          receiver:  socket,
          selector:  :write,
          arguments: [[ping_response_body.bytesize].pack('V')]
        },
        {
          receiver:  socket,
          selector:  :write,
          arguments: [ping_response_body]
        },
        {
          receiver: socket,
          selector: :flush
        }
      ]
    end

    let(:read_exit) do
      [
        {
          receiver:  socket,
          selector:  :read,
          arguments: [4],
          reaction:  { return: [exit_body.bytesize].pack('V') }
        },
        {
          receiver:  socket,
          selector:  :read,
          arguments: [exit_body.bytesize],
          reaction:  { return: exit_body }
        },
        {
          receiver:  json,
          selector:  :parse,
          arguments: [exit_body],
          reaction:  { return: { 'type' => 'exit' } }
        }
      ]
    end

    let(:write_exit_response) do
      [
        {
          receiver:  json,
          selector:  :generate,
          arguments: [nil],
          reaction:  { return: exit_response_body }
        },
        {
          receiver:  socket,
          selector:  :write,
          arguments: [[exit_response_body.bytesize].pack('V')]
        },
        {
          receiver:  socket,
          selector:  :write,
          arguments: [exit_response_body]
        },
        {
          receiver: socket,
          selector: :flush
        }
      ]
    end

    context 'with ping then exit messages' do
      let(:raw_expectations) do
        [
          *create_socket,
          *read_ping,
          *write_ping_response,
          *read_exit,
          *write_exit_response,
          *close_socket
        ]
      end

      it 'returns success' do
        verify_events { expect(apply).to eql(Mutant::Either::Right.new(nil)) }
      end
    end

    context 'with exit message only' do
      let(:raw_expectations) do
        [
          *create_socket,
          *read_exit,
          *write_exit_response,
          *close_socket
        ]
      end

      it 'returns success' do
        verify_events { expect(apply).to eql(Mutant::Either::Right.new(nil)) }
      end
    end

    context 'with EOF reading header' do
      let(:raw_expectations) do
        [
          *create_socket,
          {
            receiver:  socket,
            selector:  :read,
            arguments: [4],
            reaction:  { return: nil }
          },
          *close_socket
        ]
      end

      it 'raises error' do
        verify_events do
          expect { apply }.to raise_error(described_class::Error, 'Unexpected EOF reading header')
        end
      end
    end

    context 'with EOF reading body' do
      let(:raw_expectations) do
        [
          *create_socket,
          {
            receiver:  socket,
            selector:  :read,
            arguments: [4],
            reaction:  { return: [ping_body.bytesize].pack('V') }
          },
          {
            receiver:  socket,
            selector:  :read,
            arguments: [ping_body.bytesize],
            reaction:  { return: nil }
          },
          *close_socket
        ]
      end

      it 'raises error' do
        verify_events do
          expect { apply }.to raise_error(described_class::Error, 'Unexpected EOF reading body')
        end
      end
    end

    context 'with unknown message type' do
      let(:unknown_body) { '{"type":"unknown"}' }

      let(:raw_expectations) do
        [
          *create_socket,
          {
            receiver:  socket,
            selector:  :read,
            arguments: [4],
            reaction:  { return: [unknown_body.bytesize].pack('V') }
          },
          {
            receiver:  socket,
            selector:  :read,
            arguments: [unknown_body.bytesize],
            reaction:  { return: unknown_body }
          },
          {
            receiver:  json,
            selector:  :parse,
            arguments: [unknown_body],
            reaction:  { return: { 'type' => 'unknown' } }
          },
          *close_socket
        ]
      end

      it 'raises error' do
        verify_events do
          expect { apply }.to raise_error(
            described_class::Error,
            'Unknown message type: {"type" => "unknown"}'
          )
        end
      end
    end

    context 'with socket creation failure' do
      let(:raw_expectations) do
        [
          {
            receiver:  unix_socket,
            selector:  :new,
            arguments: [socket_path],
            reaction:  { exception: Errno::ECONNREFUSED.new }
          }
        ]
      end

      it 'raises error without calling close' do
        verify_events do
          expect { apply }.to raise_error(Errno::ECONNREFUSED)
        end
      end
    end
  end
end
