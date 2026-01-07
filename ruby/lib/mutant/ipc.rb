# frozen_string_literal: true

module Mutant
  class IPC
    include Anima.new(:socket_path, :world)

    Error = Class.new(RuntimeError)

    def call
      @continue = true
      socket = world.unix_socket.new(socket_path)

      while @continue
        message = read_message(socket)
        response = handle_message(message)
        write_message(socket, response)
      end

      Either::Right.new(nil)
    ensure
      socket&.close
    end

  private

    def read_message(socket)
      header = socket.read(4) or raise Error, 'Unexpected EOF reading header'

      length = header.unpack1('V')
      body = socket.read(length) or raise Error, 'Unexpected EOF reading body'

      world.json.parse(body)
    end

    def write_message(socket, value)
      body = world.json.generate(value)
      socket.write([body.bytesize].pack('V'))
      socket.write(body)
      socket.flush
    end

    def handle_message(message)
      case message.fetch('type')
      when 'ping'
        message.fetch('payload')
      when 'exit'
        @continue = false
        nil
      else
        raise Error, "Unknown message type: #{message}"
      end
    end
  end # IPC
end # Mutant
