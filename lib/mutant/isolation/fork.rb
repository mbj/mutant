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
      include(Adamantium, Concord.new(:world))

      READ_SIZE = 4096

      ATTRIBUTES = %i[block deadline log_pipe result_pipe world].freeze

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

      # rubocop:disable Metrics/ClassLength
      class Parent
        include(Anima.new(*ATTRIBUTES), Procto)

        # Prevent mutation from `process.fork` to `fork` to call Kernel#fork
        undef_method :fork

        # Parent process
        #
        # @return [Result]
        def call
          @exception     = nil
          @log_fragments = []
          @timeout       = nil
          @value         = nil
          @pid           = start_child

          read_child_result
          result
        end

      private

        def result
          Result.new(
            exception:      @exception,
            log:            @log_fragments.join,
            process_status: @process_status,
            timeout:        @timeout,
            value:          @value
          )
        end

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
            load_result(result_fragments)
            terminate_graceful
          else
            @timeout = deadline.allowed_time
            terminate_ungraceful
          end
        end
        # rubocop:enable Metrics/MethodLength

        def load_result(result_fragments)
          @value = world.marshal.load(result_fragments.join)
        rescue ArgumentError => exception
          @exception = exception
        end

        # rubocop:disable Metrics/MethodLength
        def read_targets(targets)
          until targets.empty?
            status = deadline.status

            break unless status.ok?

            ready, = world.io.select(targets.keys, [], [], status.time_left)

            break unless ready

            ready.each do |target|
              if target.eof?
                targets.delete(target)
              else
                read_fragment(target, targets.fetch(target))
              end
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        def read_fragment(target, fragments)
          loop do
            result = target.read_nonblock(READ_SIZE, exception: false)
            break unless result.instance_of?(String)
            fragments << result
            break if result.bytesize < READ_SIZE
          end
        end

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
          @process_status = status
        end

        def peek_child
          _pid, status = world.process.wait2(@pid, Process::WNOHANG)
          status
        end

        def add_result(result)
          @result = defined?(@result) ? @result.add_error(result) : result
        end
      end # Parent
      # rubocop:enable Metrics/ClassLength

      class Child
        include(Adamantium, Anima.new(*ATTRIBUTES), Procto)

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

      private_constant(*constants(false))

      # Call block in isolation
      #
      # @return [Result]
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
