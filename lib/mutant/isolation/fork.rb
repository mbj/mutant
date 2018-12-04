# frozen_string_literal: true

module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    class Fork < self
      include Anima.new(:process, :stderr, :stdout, :io, :devnull, :marshal)

      # Prevent mutation from `process.fork` to `fork` to call Kernel#fork
      undef_method :fork

      # Call block in isolation
      #
      # @return [Result]
      #   execution result
      def call(&block)
        io.pipe(binmode: true) do |pipes|
          parent(*pipes, &block)
        end
      rescue => exception
        Result::Error.new(exception)
      end

      # Handle parent process
      #
      # @param [IO] reader
      # @param [IO] writer
      #
      # @return [undefined]
      def parent(reader, writer, &block)
        pid = process.fork do
          child(reader, writer, &block)
        end

        writer.close

        Result::Success.new(marshal.load(reader)).tap do
          process.waitpid(pid)
        end
      end

      # Handle child process
      #
      # @param [IO] reader
      # @param [IO] writer
      #
      # @return [undefined]
      def child(reader, writer, &block)
        reader.close
        writer.binmode
        writer.syswrite(marshal.dump(result(&block)))
        writer.close
      end

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

    end # Fork
  end # Isolation
end # Mutant
