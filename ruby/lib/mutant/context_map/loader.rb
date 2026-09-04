# frozen_string_literal: true

module Mutant
  class ContextMap
    # Reads simplecov's `coverage.json` into a ContextMap
    #
    # Every way the read can fail ends in an explanation of how to produce the
    # recording, because the recording is the whole reason the strategy was
    # asked for.
    #
    # rubocop:disable Metrics/ClassLength
    class Loader
      include Anima.new(:artifact, :world)

      MISSING_ARTIFACT = <<~'MESSAGE'
        Test selection strategy `context_map` needs a per test coverage recording,
        but none exists at:

          %<path>s

        Record one with simplecov 1.2.0 or newer:

          # spec/spec_helper.rb, or test/test_helper.rb
          require 'simplecov'
          SimpleCov.start do
            track_tests
          end

        Run the test suite once to write the recording, then re-run mutant. The
        default HTML formatter writes `coverage.json` beside its report, as does
        `SimpleCov::Formatter::JSONFormatter`.

        Pass `--selection-path DIRECTORY` if the recording is not under ./coverage.
      MESSAGE

      UNREADABLE_ARTIFACT = <<~'MESSAGE'
        Unable to read the coverage recording at:

          %<path>s

        %<error>s
      MESSAGE

      INVALID_ARTIFACT = <<~'MESSAGE'
        The coverage recording at:

          %<path>s

        is not a simplecov report mutant can read. Delete it and record it again
        with simplecov 1.2.0 or newer.
      MESSAGE

      UNKNOWN_SCHEMA = <<~'MESSAGE'
        The coverage recording at:

          %<path>s

        uses report schema version %<schema>s, which mutant does not understand.
        Upgrade mutant, or record again with a simplecov that writes schema
        version 1.
      MESSAGE

      NO_CONTEXTS = <<~'MESSAGE'
        The coverage recording at:

          %<path>s

        has no per test data, so mutant cannot tell which tests cover a subject.

        Enable tracking with simplecov 1.2.0 or newer:

          SimpleCov.start do
            track_tests
          end

        Run the test suite once with tracking enabled, then re-run mutant.
      MESSAGE

      CONTEXT_INDEX = /\A\d+\z/
      LINE_BITMAP   = /\A\h+\z/

      private_constant(*constants(false))

      # Load the recording under path
      #
      # @return [Either<String, ContextMap>]
      def self.call(path:, world:)
        artifact = path.file? ? path : path.join(ARTIFACT_BASENAME)

        new(artifact:, world:).call
      end

      # Load the recording
      #
      # @return [Either<String, ContextMap>]
      def call
        return error(MISSING_ARTIFACT) unless artifact.file?

        read.bind(&method(:parse)).bind(&method(:from_document))
      end

    private

      def read
        Either
          .wrap_error(SystemCallError) { artifact.read }
          .lmap { |exception| unreadable(exception) }
      end

      def parse(contents)
        world.parse_json(contents).lmap { |exception| unreadable(exception) }
      end

      def unreadable(exception)
        UNREADABLE_ARTIFACT % { error: exception, path: artifact }
      end

      def error(message, **arguments)
        Either::Left.new(message % { path: artifact, **arguments })
      end

      def from_document(data)
        return error(INVALID_ARTIFACT) unless data.instance_of?(Hash)

        meta = data.fetch('meta', nil)

        return error(INVALID_ARTIFACT) unless meta.instance_of?(Hash)

        schema = meta.fetch('schema_version', nil)

        return error(UNKNOWN_SCHEMA, schema: schema.inspect) unless supported_schema?(schema)

        root = meta.fetch('root', nil)

        return error(INVALID_ARTIFACT) unless root.instance_of?(String)

        from_contexts(data:, root:)
      end

      def supported_schema?(schema)
        schema.instance_of?(String) && schema.match?(SUPPORTED_SCHEMA)
      end

      def from_contexts(data:, root:)
        contexts = data.fetch('contexts', nil)

        return error(NO_CONTEXTS) unless contexts

        tables = load_tables(contexts:, coverage: data.fetch('coverage', nil), root:)

        tables ? Either::Right.new(ContextMap.new(root:, tables:)) : error(INVALID_ARTIFACT)
      end

      # nil on anything malformed. A half read recording would answer coverage
      # questions with silent gaps, and a silent gap is a mutation reported
      # alive that no test was ever given the chance to kill.
      def load_tables(contexts:, coverage:, root:)
        return unless valid_contexts?(contexts) && valid_coverage?(coverage)

        normalized = contexts.map { |context| ContextMap.normalize(context, root) }

        coverage.each_with_object({}) do |(file, entry), tables|
          table = entry.fetch('contexts', nil) or next

          decoded = load_table(contexts: normalized, table:) or return nil

          tables[File.expand_path(file.delete_prefix('/'), root)] = decoded
        end
      end

      def valid_contexts?(contexts)
        contexts.instance_of?(Array) && contexts.all?(String)
      end

      # A file with no `contexts` section is one no recorded test executed, and
      # contributes nothing rather than making the recording unreadable.
      def valid_coverage?(coverage)
        coverage.instance_of?(Hash) && coverage.each_value.all?(Hash)
      end

      def load_table(contexts:, table:)
        return unless table.instance_of?(Hash)

        table.each_with_object({}) do |(index, encoded), decoded|
          context = decode_context(contexts:, index:)
          bitmap  = decode_bitmap(encoded)

          return nil unless context && bitmap

          decoded[context] = decoded.fetch(context, 0) | bitmap
        end
      end

      def decode_context(contexts:, index:)
        return unless index.match?(CONTEXT_INDEX)

        contexts.at(index.to_i)
      end

      def decode_bitmap(encoded)
        return unless encoded.instance_of?(String) && encoded.match?(LINE_BITMAP)

        encoded.hex
      end
    end # Loader
    # rubocop:enable Metrics/ClassLength
  end # ContextMap
end # Mutant
