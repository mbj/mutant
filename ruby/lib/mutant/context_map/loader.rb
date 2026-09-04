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

        is not a simplecov report mutant can read:

          %<error>s

        Delete it and record it again with simplecov 1.2.0 or newer.
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

      UNKNOWN_CONTEXT = '%<file>s refers to a context the recording does not list'
      NOT_DIGITS      = 'Expected: digits in base %<base>d but got: %<actual>s'

      # An integer written as digits in a base, and nothing else
      #
      # Kernel#Integer would also take a sign, a prefix, whitespace or
      # underscores, none of which the format allows.
      def self.parse_digits(string, base:, pattern:)
        if string.match?(pattern)
          Either::Right.new(Integer(string, base))
        else
          Either::Left.new(NOT_DIGITS % { actual: string.inspect, base: })
        end
      end
      private_class_method :parse_digits

      CONTEXT_INDEX = Transform::Sequence.new(
        steps: [
          Transform::STRING,
          Transform::Block.capture(:decimal) { |string| parse_digits(string, base: 10, pattern: /\A\d+\z/) }
        ]
      )

      LINE_BITMAP = Transform::Sequence.new(
        steps: [
          Transform::STRING,
          Transform::Block.capture(:hexadecimal) { |string| parse_digits(string, base: 16, pattern: /\A\h+\z/) }
        ]
      )

      # Per source file: the index of each test that executed it, and a bitmap
      # of the lines it executed
      TABLE = Transform::Hash::Map.new(key: CONTEXT_INDEX, value: LINE_BITMAP)

      # The report carries far more than mutant reads, and gains keys between
      # minor schema versions. Each hash below is sliced to the keys mutant
      # names before the strict transform sees it.
      #
      # A file with no `contexts` section is one no recorded test executed, and
      # contributes nothing rather than making the recording unreadable.
      FILE = Transform::Sequence.new(
        steps: [
          Transform::Hash::Slice.new(keys: %w[contexts]),
          Transform::Hash.new(
            optional: [Transform::Hash::Key.new(value: 'contexts', transform: TABLE)],
            required: []
          )
        ]
      )

      META = Transform::Sequence.new(
        steps: [
          Transform::Hash::Slice.new(keys: %w[root schema_version]),
          Transform::Hash.new(
            optional: [],
            required: [
              Transform::Hash::Key.new(value: 'root',           transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'schema_version', transform: Transform::STRING)
            ]
          )
        ]
      )

      COVERAGE = Transform::Hash::Map.new(key: Transform::STRING, value: FILE)

      DOCUMENT = Transform::Sequence.new(
        steps: [
          Transform::Hash::Slice.new(keys: %w[contexts coverage meta]),
          Transform::Hash.new(
            optional: [Transform::Hash::Key.new(value: 'contexts', transform: Transform::STRING_ARRAY)],
            required: [
              Transform::Hash::Key.new(value: 'coverage', transform: COVERAGE),
              Transform::Hash::Key.new(value: 'meta',     transform: META)
            ]
          )
        ]
      )

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

        read
          .bind(&method(:parse))
          .bind(&method(:decode))
          .bind(&method(:from_document))
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

      def decode(data)
        DOCUMENT.call(data).lmap { |error| INVALID_ARTIFACT % { error: error.compact_message, path: artifact } }
      end

      def unreadable(exception)
        UNREADABLE_ARTIFACT % { error: exception, path: artifact }
      end

      def error(message, **arguments)
        Either::Left.new(message % { path: artifact, **arguments })
      end

      def from_document(document)
        meta   = document.fetch('meta')
        schema = meta.fetch('schema_version')

        return error(UNKNOWN_SCHEMA, schema: schema.inspect) unless schema.match?(SUPPORTED_SCHEMA)

        contexts = document.fetch('contexts', nil) or return error(NO_CONTEXTS)

        load_tables(contexts:, coverage: document.fetch('coverage'), root: meta.fetch('root'))
      end

      def load_tables(contexts:, coverage:, root:)
        ids = contexts.map { |context| ContextMap.normalize(context, root) }

        tables = coverage.each_with_object({}) do |(file, entry), tables|
          table = entry.fetch('contexts', nil) or next

          resolved = resolve(ids:, table:) or return error(INVALID_ARTIFACT, error: UNKNOWN_CONTEXT % { file: })

          tables[File.expand_path(file.delete_prefix('/'), root)] = resolved
        end

        Either::Right.new(ContextMap.new(root:, tables:))
      end

      # nil on an index outside the recording's list. A half read recording
      # would answer coverage questions with silent gaps, and a silent gap is
      # a mutation reported alive that no test was ever given the chance to
      # kill.
      def resolve(ids:, table:)
        table.each_with_object({}) do |(index, bitmap), resolved|
          id = ids.at(index) or return nil

          resolved[id] = resolved.fetch(id, 0) | bitmap
        end
      end
    end # Loader
    # rubocop:enable Metrics/ClassLength
  end # ContextMap
end # Mutant
