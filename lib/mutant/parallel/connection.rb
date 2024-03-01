# frozen_string_literal: true

module Mutant
  module Parallel
    class Connection
      include Anima.new(:marshal, :reader, :writer)

      Error = Class.new(RuntimeError)

      HEADER_FORMAT = 'N'
      HEADER_SIZE   = 4
      MAX_BYTES     = (2**32).pred

      class Reader
        include Anima.new(:deadline, :io, :marshal, :response_reader, :log_reader)

        private(*anima.attribute_names)

        private_class_method :new

        attr_reader :log

        def error
          @errors.first
        end

        def result
          @results.first
        end

        def initialize(*)
          super

          @buffer  = +''
          @log     = +''

          # Array of size max 1 as surrogate for
          # terrible default nil ivars.
          @errors  = []
          @lengths = []
          @results = []
        end

        def self.read_response(**attributes)
          reader = new(**attributes).read_till_final

          Response.new(
            log:    reader.log,
            error:  reader.error,
            result: reader.result
          )
        end

        # rubocop:disable Metrics/MethodLength
        def read_till_final
          readers = [response_reader, log_reader]

          until result || error
            status = deadline.status

            break timeout unless status.ok?

            reads, _others = io.select(readers, nil, nil, status.time_left)

            break timeout unless reads

            reads.each do |ready|
              if ready.equal?(response_reader)
                advance_result
              else
                advance_log
              end
            end
          end

          self
        end
      # rubocop:enable Metrics/MethodLength

      private

        def timeout
          @errors << Timeout
        end

        def advance_result
          if length
            if read_buffer(length)
              @results << marshal.load(@buffer)
            end
          elsif read_buffer(HEADER_SIZE)
            @lengths << Util.one(@buffer.unpack(HEADER_FORMAT))
            @buffer = +''
          end
        end

        def length
          @lengths.first
        end

        def advance_log
          with_nonblock_read(io: log_reader, max_bytes: 4096, &log.public_method(:<<))
        end

        def read_buffer(max_bytes)
          with_nonblock_read(
            io:        response_reader,
            max_bytes: max_bytes - @buffer.bytesize
          ) do |chunk|
            @buffer << chunk
            @buffer.bytesize.equal?(max_bytes)
          end
        end

        # rubocop:disable Metrics/MethodLength
        def with_nonblock_read(io:, max_bytes:)
          io.binmode

          chunk = io.read_nonblock(max_bytes, exception: false)

          case chunk
          when nil
            @errors << EOFError
            false
          when String
            yield chunk
          else
            fail "Unexpected nonblocking read return: #{chunk.inspect}"
          end
        end
        # rubocop:enable Metrics/MethodLength
      end

      class Frame
        include Anima.new(:io)

        def receive_value
          read(Util.one(read(HEADER_SIZE).unpack(HEADER_FORMAT)))
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
    end # Connection
  end # Parallel
end # Mutant
