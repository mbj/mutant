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
      def self.call(&block)
        block.call
      rescue => exception
        raise Error, exception
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
      # rubocop:disable MethodLength
      #
      # @api private
      def self.call(&block)
        IO.pipe(binmode: true) do |reader, writer|
          writer.binmode
          begin
            pid = Process.fork do
              File.open(File::NULL, 'w') do |file|
                $stderr.reopen(file)
                reader.close
                writer.write(Marshal.dump(block.call))
                writer.close
              end
            end

            writer.close
            Marshal.load(reader.read)
          ensure
            Process.waitpid(pid) if pid
          end
        end
      rescue => exception
        raise Error, exception
      end

    end # Fork

  end # Isolator
end # Mutant
