module Mutant
  # Module providing isolationg
  module Isolation
    Error = Class.new(RuntimeError)

    # Call block in isolation
    #
    # This isolation implements the fork strategy.
    # Future strategies will probably use a process pool that can
    # handle multiple mutation kills, in-isolation at once.
    #
    # @return [Object]
    #
    # @raise [Error]
    #
    # @api private
    #
    def self.call(&block)
      reader, writer = IO.pipe.each(&:binmode)

      pid = fork

      if pid.nil?
        begin
          reader.close
          writer.write(Marshal.dump(block.call))
          Kernel.exit!(0)
        ensure
          Kernel.exit!(1)
        end
      end

      writer.close

      read_result(reader, pid)
    end

    # Read result from child process
    #
    # @param [IO] reader
    # @param [Fixnum] pid
    #
    # @return [Object]
    #
    # @raise [Error]
    #
    def self.read_result(reader, pid)
      begin
        data = Marshal.load(reader.read)
      rescue ArgumentError, TypeError
        raise Error, 'Childprocess wrote un-unmarshallable data'
      end

      status = Process.waitpid2(pid).last

      unless status.exitstatus.zero?
        raise Error, "Childprocess exited with nonzero exit status: #{status.exitstatus}"
      end

      data
    end
    private_class_method :read_result

  end # Isolator
end # Mutant
