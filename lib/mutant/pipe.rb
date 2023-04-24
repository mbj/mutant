# frozen_string_literal: true

module Mutant
  # Pipe abstraction
  class Pipe
    include Adamantium, Anima.new(:reader, :writer)

    # Run block with pipe in binmode
    #
    # @return [undefined]
    def self.with(io)
      io.pipe(binmode: true) do |(reader, writer)|
        yield new(reader: reader, writer: writer)
      end
    end

    def self.from_io(io)
      reader, writer = io.pipe(binmode: true)
      new(reader: reader, writer: writer)
    end

    # Writer end of the pipe
    #
    # @return [IO]
    def to_writer
      reader.close
      writer
    end

    # Parent reader end of the pipe
    #
    # @return [IO]
    def to_reader
      writer.close
      reader
    end

    class Connection
      include Anima.new(:marshal, :reader, :writer)

      Error = Class.new(RuntimeError)

      class Frame
        include Anima.new(:io)

        HEADER_FORMAT = 'N'
        MAX_BYTES     = (2**32).pred
        HEADER_SIZE   = 4

        def receive_value
          header = read(HEADER_SIZE)
          read(Util.one(header.unpack(HEADER_FORMAT)))
        end

        def send_value(body)
          bytesize = body.bytesize

          fail Error, 'message to big' if bytesize > MAX_BYTES

          io.binmode
          io.write([bytesize].pack(HEADER_FORMAT))
          io.write(body)
        end

      private

        def read(bytes)
          io.binmode
          io.read(bytes) or fail Error, 'Unexpected EOF'
        end
      end

      def call(payload)
        send_value(payload)
        receive_value
      end

      def receive_value
        marshal.load(reader.receive_value)
      end

      def send_value(value)
        writer.send_value(marshal.dump(value))
        self
      end

      def self.from_pipes(marshal:, reader:, writer:)
        new(
          marshal: marshal,
          reader:  Frame.new(io: reader.to_reader),
          writer:  Frame.new(io: writer.to_writer)
        )
      end
    end
  end # Pipe
end # Mutant
