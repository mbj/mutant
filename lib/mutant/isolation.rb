module Mutant
  # Module providing isolation
  module Isolation
    Error = Class.new(RuntimeError)

    module None

      # Call block in isolation
      #
      # @return [Object]
      #
      # @raise [Error]
      #   if block terminates abnormal
      #
      # @api private
      #
      def self.call(&block)
        block.call
      rescue => exception
        fail Error, exception
      end
    end

    module Fork

      # Call block in isolation
      #
      # This isolation implements the fork strategy.
      # Future strategies will probably use a process pool that can
      # handle multiple mutation kills, in-isolation at once.
      #
      # @return [Object]
      #   returns block execution result
      #
      # @raise [Error]
      #   if block terminates abnormal
      #
      # @api private
      #
      def self.call(&block)
        reader, writer = IO.pipe.map(&:binmode)

        pid = Process.fork do
          File.open('/dev/null', 'w') do |file|
            $stderr.reopen(file)
            reader.close
            writer.write(Marshal.dump(block.call))
            writer.close
          end
        end

        writer.close
        Marshal.load(reader.read)
      rescue => exception
        fail Error, exception
      ensure
        Process.waitpid(pid) if pid
      end

    end # Fork

  end # Isolator
end # Mutant
