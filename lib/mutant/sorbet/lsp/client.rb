# frozen_string_literal: true

module Mutant
  module Sorbet
    module LSP
      # JSON-RPC message for Language Server Protocol
      class Message
        include Anima.new(:content)

        # Parse message from LSP wire format
        def self.read(io, timeout: nil)
          return nil if io.closed?

          # Use select to implement timeout
          if timeout
            ready = IO.select([io], nil, nil, timeout)
            return nil unless ready
          end

          # Read headers
          headers = {}
          loop do
            line = io.gets("\r\n")
            return nil unless line

            line = line.strip
            break if line.empty?

            if line =~ /^([^:]+):\s*(.+)$/
              headers[$1] = $2
            end
          end

          # Read content
          length = headers['Content-Length']&.to_i
          return nil unless length && length > 0

          json = io.read(length)
          return nil unless json

          new(content: JSON.parse(json, symbolize_names: true))
        rescue JSON::ParserError, IOError, Errno::EPIPE
          nil
        end

        # Write message to LSP wire format
        def write(io)
          json = JSON.generate(content)
          io.write("Content-Length: #{json.bytesize}\r\n\r\n#{json}")
          io.flush
        rescue IOError, Errno::EPIPE
          false
        end

        def id
          content[:id]
        end

        def method_name
          content[:method]
        end

        def notification?
          !content.key?(:id)
        end

        def request?
          content.key?(:id) && content.key?(:method)
        end

        def response?
          content.key?(:id) && !content.key?(:method)
        end
      end

      # LSP Client for Sorbet
      class Client
        def self.find_sorbet_binary
          spec = Gem::Specification.find_by_name('sorbet-static')
          File.join(spec.gem_dir, 'libexec', 'sorbet')
        end

        def initialize(project_root:, binary: self.class.find_sorbet_binary, cache_dir: nil)
          @project_root = Pathname.new(project_root).expand_path
          @binary = binary
          @cache_dir = cache_dir ? Pathname.new(cache_dir).expand_path : nil
          @request_id = 0
          @mutex = Mutex.new
          @pending_responses = {}
          @diagnostics = {}
          @running = false
        end

        # Start the LSP server
        def start
          args = [@binary, '--lsp', '--disable-watchman', '--dir', @project_root.to_s]
          args.concat(['--cache-dir', @cache_dir.to_s]) if @cache_dir

          @stdin, @stdout, @stderr, @thread = Open3.popen3(
            *args,
            chdir: @project_root.to_s
          )

          @running = true

          # Start reader thread
          @reader_thread = Thread.new { read_loop }

          # Initialize LSP
          response = send_request(
            method: 'initialize',
            params: {
              processId: Process.pid,
              rootUri: file_uri(@project_root),
              capabilities: {
                textDocument: {
                  synchronization: {
                    didOpen: true,
                    didChange: true,
                    didClose: true
                  }
                }
              },
              initializationOptions: {}
            }
          )

          raise "Initialize failed: #{response}" if response[:error]

          # Send initialized notification
          send_notification(method: 'initialized', params: {})

          self
        end

        # Stop the LSP server
        def stop
          return unless @running

          @running = false

          begin
            send_request(method: 'shutdown', params: {})
            send_notification(method: 'exit', params: {})
          rescue
            # Ignore errors during shutdown
          end

          @reader_thread&.kill
          @stdin.close rescue nil
          @stdout.close rescue nil
          @stderr.close rescue nil

          if @thread&.alive?
            Process.kill('TERM', @thread.pid) rescue nil
            @thread.join(2)
            Process.kill('KILL', @thread.pid) if @thread.alive?
          end

          self
        end

        # Get diagnostics for a file
        def diagnostics_for(file_path)
          uri = file_uri(file_path)
          @mutex.synchronize { @diagnostics[uri] || [] }
        end

        # Open a document in the LSP server
        def open_document(file_path:, content:)
          send_notification(
            method: 'textDocument/didOpen',
            params: {
              textDocument: {
                uri: file_uri(file_path),
                languageId: 'ruby',
                version: 1,
                text: content
              }
            }
          )
          self
        end

        # Change document content
        def change_document(file_path:, content:, version:)
          send_notification(
            method: 'textDocument/didChange',
            params: {
              textDocument: {
                uri: file_uri(file_path),
                version: version
              },
              contentChanges: [{ text: content }]
            }
          )
          self
        end

        # Close a document
        def close_document(file_path:)
          send_notification(
            method: 'textDocument/didClose',
            params: {
              textDocument: {
                uri: file_uri(file_path)
              }
            }
          )
          self
        end

        # Wait for diagnostics to settle (no new ones for a period)
        def wait_for_diagnostics(timeout: 5, settle_time: 0.5)
          start = Time.now
          last_change = Time.now

          loop do
            @mutex.synchronize { last_change = Time.now if @diagnostics_changed }
            @diagnostics_changed = false

            # Check if settled
            return true if Time.now - last_change > settle_time

            # Check timeout
            return false if Time.now - start > timeout

            sleep 0.1
          end
        end

      private

        def file_uri(path)
          absolute = Pathname.new(path).expand_path
          "file://#{absolute}"
        end

        def send_request(method:, params:)
          id = next_request_id
          message = Message.new(
            content: {
              jsonrpc: '2.0',
              id: id,
              method: method,
              params: params
            }
          )

          # Setup response waiting
          promise = Queue.new
          @mutex.synchronize { @pending_responses[id] = promise }

          # Send message
          message.write(@stdin)

          # Wait for response (with timeout)
          response = nil
          thread = Thread.new { response = promise.pop }

          unless thread.join(30) # 30 second timeout
            thread.kill
            @mutex.synchronize { @pending_responses.delete(id) }
            raise "Request timeout: #{method}"
          end

          response
        end

        def send_notification(method:, params:)
          message = Message.new(
            content: {
              jsonrpc: '2.0',
              method: method,
              params: params
            }
          )

          message.write(@stdin)
        end

        def next_request_id
          @mutex.synchronize { @request_id += 1 }
        end

        def read_loop
          while @running
            message = Message.read(@stdout, timeout: 0.5)
            next unless message

            handle_message(message)
          end
        rescue => _error
          # Server died or connection closed
          @running = false
        end

        def handle_message(message)
          if message.response?
            # Response to our request
            @mutex.synchronize do
              promise = @pending_responses.delete(message.id)
              promise&.push(message.content)
            end
          elsif message.notification?
            # Server notification
            handle_notification(message)
          end
        end

        def handle_notification(message)
          case message.method_name
          when 'textDocument/publishDiagnostics'
            handle_diagnostics(message.content[:params])
          when 'window/showMessage', 'window/logMessage'
            # Ignore for now
          end
        end

        def handle_diagnostics(params)
          uri = params[:uri]
          diagnostics = params[:diagnostics] || []

          @mutex.synchronize do
            @diagnostics[uri] = diagnostics
            @diagnostics_changed = true
          end
        end
      end
    end
  end
end
