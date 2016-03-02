module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    #
    # We do inject so many globals and common patterns to make this unit
    # specifiable without mocking the globals and more important: Not having
    # mutations that bypass mocks into a real world side effect.
    class Fork < self
      include Anima.new(:process, :stderr, :stdout, :io, :devnull, :marshal)

      # Prevent mutation from `process.fork` to `fork` to call Kernel#fork
      undef_method :fork

      # Call block in isolation
      #
      # @return [Object]
      #   returns block execution result
      #
      # @raise [Error]
      #   if block terminates abnormal
      def call(&block)
        io.pipe(binmode: true) do |pipes|
          parent(*pipes, &block)
        end
      rescue => exception
        raise Error, exception
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
        marshal.load(reader)
      ensure
        process.waitpid(pid) if pid
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
