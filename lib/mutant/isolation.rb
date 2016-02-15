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
      def self.call(&block)
        IO.pipe(binmode: true) do |reader, writer|
          writer.binmode
          begin
            pid = Process.fork do
              File.open(File::NULL, File::WRONLY) do |file|
                $stderr.reopen(file)
                reader.close
                writer.write(Marshal.dump(block.call))
                writer.close
              end
            end

            writer.close
            result = Marshal.load(reader.read)
            if result.is_a?(Mutant::Result::Test)
              result
            else
              raise Error, result.to_s
            end
          ensure
            Process.waitpid(pid) if pid
          end
        end
      rescue Error => exception
        raise exception
      rescue => exception
        raise Error, exception
      end

    end # Fork

  end # Isolator
end # Mutant
