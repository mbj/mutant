# frozen_string_literal: true

module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    #
    # Communication between parent and child process is done
    # via anonymous pipes.
    #
    # Timeouts are initially handled relatively efficiently via IO.select
    # but once the child process pipes are on eof via busy looping on
    # waitpid2 with Process::WNOHANG set.
    #
    # Handling timeouts this way is not the conceptually most
    # efficient solution. But its cross platform.
    #
    # Design constraints:
    #
    # * Support Linux
    # * Support MacOSX
    # * Avoid platform specific APIs and code.
    # * Only use ruby corelib.
    # * Do not use any named resource.
    # * Never block on latency inducing systemcall without a
    #   timeout.
    # * Child process freezing before closing the pipes needs to
    #   be detected by parent process.
    # * Child process freezing after closing the pipes needs to be
    #   detected by parent process.
    class Fork < self
      include(Adamantium::Flat, Concord.new(:world))

      READ_SIZE = 4096

      ATTRIBUTES = %i[block deadline log_pipe result_pipe world].freeze

      # Unsuccessful result as child exited nonzero
      class ChildError < Result
        include Concord::Public.new(:value, :log)
      end # ChildError

      # Unsuccessful result as fork failed
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
          @log_fragments = []

          @pid = start_child or return ForkError.new

          read_child_result

          @result
        end

      private

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

        # rubocop:disable Metrics/MethodLength
        def read_child_result
          result_fragments = []

          targets =
            {
              log_pipe.parent    => @log_fragments,
              result_pipe.parent => result_fragments
            }

          read_targets(targets)

          if targets.empty?
            read_result(result_fragments)
            terminate_graceful
          else
            add_result(Result::Timeout.new(deadline.allowed_time))
            terminate_ungraceful
          end
        end
        # rubocop:enable Metrics/MethodLength

        def read_result(result_fragments)
          result = world.marshal.load(result_fragments.join)
        rescue ArgumentError => exception
          add_result(Result::Exception.new(exception))
        else
          add_result(Result::Success.new(result, @log_fragments.join))
        end

        # rubocop:disable Metrics/MethodLength
        def read_targets(targets)
          until targets.empty?
            status = deadline.status

            break unless status.ok?

            ready, = world.io.select(targets.keys, [], [], status.time_left)

            break unless ready

            ready.each do |fd|
              if fd.eof?
                targets.delete(fd)
              else
                targets.fetch(fd) << fd.read_nonblock(READ_SIZE)
              end
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def terminate_graceful
          status = nil

          loop do
            status = peek_child
            break if status || deadline.expired?
            world.kernel.sleep(0.1)
          end

          if status
            handle_status(status)
          else
            terminate_ungraceful
          end
        end
        # rubocop:enable Metrics/MethodLength

        def terminate_ungraceful
          world.process.kill('KILL', @pid)

          _pid, status = world.process.wait2(@pid)

          handle_status(status)
        end

        def handle_status(status)
          unless status.success? # rubocop:disable Style/GuardClause
            add_result(ChildError.new(status, @log_fragments.join))
          end
        end

        def peek_child
          _pid, status = world.process.wait2(@pid, Process::WNOHANG)
          status
        end

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
      # rubocop:disable Metrics/MethodLength
      def call(timeout, &block)
        deadline = world.deadline(timeout)
        io = world.io
        Pipe.with(io) do |result|
          Pipe.with(io) do |log|
            Parent.call(
              block:       block,
              deadline:    deadline,
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
