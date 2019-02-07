# frozen_string_literal: true

module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    class Fork < self
      include(Adamantium::Flat, Concord.new(:world))

      READ_SIZE = 4096

      ATTRIBUTES = %i[block log_pipe result_pipe world].freeze

      # Unsucessful result as child exited nonzero
      class ChildError < Result
        include Concord::Public.new(:value, :log)
      end # ChildError

      # Unsucessful result as fork failed
      class ForkError < Result
        include Equalizer.new
      end # ForkError

      # Pipe abstraction
      class Pipe
        include Adamantium::Flat, Anima.new(:reader, :writer)

        # Run block with pipe in binmode
        #
        # @return [undefined]
        def self.with(io)
          io.pipe(binmode: true) do |(reader, writer)|
            yield new(reader: reader, writer: writer)
          end
        end

        # Child writer end of the pipe
        #
        # @return [IO]
        def child
          reader.close
          writer
        end

        # Parent reader end of the pipe
        #
        # @return [IO]
        def parent
          writer.close
          reader
        end
      end # Pipe

      # ignore :reek:InstanceVariableAssumption
      class Parent
        include(
          Anima.new(*ATTRIBUTES),
          Procto.call
        )

        # Prevent mutation from `process.fork` to `fork` to call Kernel#fork
        undef_method :fork

        # Parent process
        #
        # @return [Result]
        def call
          pid = start_child or return ForkError.new

          read_child_result(pid)

          @result
        end

      private

        # Start child process
        #
        # @return [Integer]
        def start_child
          world.process.fork do
            Child.call(
              to_h.merge(
                log_pipe:    log_pipe.child,
                result_pipe: result_pipe.child
              )
            )
          end
        end

        # Read child result
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        #
        # rubocop:disable Metrics/MethodLength
        def read_child_result(pid)
          result_fragments = []
          log_fragments    = []

          read_fragments(
            log_pipe.parent    => log_fragments,
            result_pipe.parent => result_fragments
          )

          begin
            result = world.marshal.load(result_fragments.join)
          rescue ArgumentError => exception
            add_result(Result::Exception.new(exception))
          else
            add_result(Result::Success.new(result, log_fragments.join))
          end
        ensure
          wait_child(pid, log_fragments)
        end
        # rubocop:enable Metrics/MethodLength

        # Read fragments
        #
        # @param [Hash{FD => Array<String}] targets
        #
        # @return [undefined]
        def read_fragments(targets)
          until targets.empty?
            ready, = world.io.select(targets.keys)

            ready.each do |fd|
              if fd.eof?
                targets.delete(fd)
              else
                targets.fetch(fd) << fd.read_nonblock(READ_SIZE)
              end
            end
          end
        end

        # Wait for child process
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        def wait_child(pid, log_fragments)
          _pid, status = world.process.wait2(pid)

          unless status.success? # rubocop:disable Style/GuardClause
            add_result(ChildError.new(status, log_fragments.join))
          end
        end

        # Add a result
        #
        # @param [Result]
        def add_result(result)
          @result = defined?(@result) ? @result.add_error(result) : result
        end
      end # Parent

      class Child
        include(
          Adamantium::Flat,
          Anima.new(*ATTRIBUTES),
          Procto.call
        )

        # Handle child process
        #
        # @return [undefined]
        def call
          world.stderr.reopen(log_pipe)
          world.stdout.reopen(log_pipe)
          result_pipe.syswrite(world.marshal.dump(block.call))
          result_pipe.close
        end

      end # Child

      private_constant(*(constants(false) - %i[ChildError ForkError]))

      # Call block in isolation
      #
      # @return [Result]
      #   execution result
      #
      # ignore :reek:NestedIterators
      #
      # rubocop:disable Metrics/MethodLength
      def call(&block)
        io = world.io
        Pipe.with(io) do |result|
          Pipe.with(io) do |log|
            Parent.call(
              block:       block,
              log_pipe:    log,
              result_pipe: result,
              world:       world
            )
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end # Fork
  end # Isolation
end # Mutant
