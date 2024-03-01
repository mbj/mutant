# frozen_string_literal: true

module Mutant
  module Parallel
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
    end # Pipe
  end # Parallel
end # Mutant
