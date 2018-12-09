# frozen_string_literal: true

module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    class Fork < self
      include(
        Adamantium::Flat,
        Anima.new(:devnull, :io, :marshal, :process, :stderr, :stdout)
      )

      ATTRIBUTES = (anima.attribute_names + %i[block reader writer]).freeze

      # Unsucessful result as child exited nonzero
      class ChildError < Result
        include Concord::Public.new(:value)
      end # ChildError

      # Unsucessful result as fork failed
      class ForkError < Result
        include Equalizer.new
      end # ForkError

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
        # @param [IO] reader
        # @param [IO] writer
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
          process.fork { Child.call(to_h) }
        end

        # Read child result
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        def read_child_result(pid)
          writer.close

          add_result(Result::Success.new(marshal.load(reader)))
        rescue ArgumentError, EOFError => exception
          add_result(Result::Exception.new(exception))
        ensure
          wait_child(pid)
        end

        # Wait for child process
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        def wait_child(pid)
          _pid, status = process.wait2(pid)

          add_result(ChildError.new(status)) unless status.success?
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
        # @param [IO] reader
        # @param [IO] writer
        #
        # @return [undefined]
        def call
          reader.close
          writer.binmode
          writer.syswrite(marshal.dump(result(&block)))
          writer.close
        end

      private

        # The block result computed under silencing
        #
        # @return [Object]
        def result
          devnull.call do |null|
            stderr.reopen(null)
            stdout.reopen(null)
            yield
          end
        end
      end # Child

      private_constant(*(constants(false) - %i[ChildError ForkError]))

      # Call block in isolation
      #
      # @return [Result]
      #   execution result
      def call(&block)
        io.pipe(binmode: true) do |(reader, writer)|
          Parent.call(to_h.merge(block: block, reader: reader, writer: writer))
        end
      end
    end # Fork
  end # Isolation
end # Mutant
