# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Session < self
        NAME              = 'session'
        SHORT_DESCRIPTION = 'Session history subcommands'

        RESULTS_DIR = '.mutant/results'

      private

        def session_files
          dir = world.pathname.new(RESULTS_DIR)

          return [] unless dir.directory?

          dir.glob('*.json')
        end

        def load_session_file(path)
          Either
            .wrap_error(JSON::ParserError) { JSON.parse(path.read) }
            .bind(&Result::Session::JSON.load_transform.public_method(:call))
        end

        # Shared base for commands that take an optional session ID argument
        class SessionCommand < self
          def parse_remaining_arguments(arguments)
            case arguments.length
            when 0 then Either::Right.new(self)
            when 1
              @session_id = Mutant::Util.one(arguments)
              Either::Right.new(self)
            else
              Either::Left.new('Expected zero or one session ID argument')
            end
          end

          def action
            path = resolve_session_path or return Either::Left.new('No sessions found')

            return Either::Left.new("Session file not found: #{path}") unless path.file?

            load_session_file(path).either(
              ->(error) { Either::Left.new("Failed to load session: #{error}") },
              method(:print_report)
            )
          end

        private

          def resolve_session_path
            if @session_id
              world.pathname.new("#{RESULTS_DIR}/#{@session_id}.json")
            else
              session_files.last
            end
          end

          abstract_method :print_report
        end # SessionCommand

        class List < self
          NAME              = 'list'
          SHORT_DESCRIPTION = 'List past mutation testing sessions'
          SUBCOMMANDS       = [].freeze

          HEADER_FORMAT = '%-36s  %-20s  %-10s  %-10s  %s'
          ROW_FORMAT    = '%-36s  %-20s  %-10s  %-10s  %s'
          UNSUPPORTED   = '[unsupported]'

          def action
            print_header
            session_files.each(&method(:print_session))

            Either::Right.new(nil)
          end

        private

          def print_header
            print(HEADER_FORMAT % ['SESSION ID', 'TIMESTAMP', 'VERSION', 'RUBY', 'SUBJECTS'])
          end

          def print_session(path)
            load_session_file(path).either(
              ->(_error) { print(colorize_unsupported(path)) },
              method(:print_session_row)
            )
          end

          def print_session_row(session)
            print(
              ROW_FORMAT % [
                session.session_id,
                session.timestamp.strftime('%Y-%m-%d %H:%M:%S'),
                session.mutant_version,
                session.ruby_version,
                session.subject_results.length
              ]
            )
          end

          def colorize_unsupported(path)
            session_id = path.basename('.json')

            ROW_FORMAT % [session_id, nil, Unparser::Color::RED.format(UNSUPPORTED), nil, nil]
          end
        end # List

        class Show < SessionCommand
          include Mutant::Reporter::CLI::Printer::AliveResults

          NAME              = 'show'
          SHORT_DESCRIPTION = 'Show results of a past session'
          SUBCOMMANDS       = [].freeze

        private

          def print_report(session)
            failed = session.subject_results.reject(&:success?)

            print("Session:  #{session.session_id}")
            print("Time:     #{session.timestamp.strftime('%Y-%m-%d %H:%M:%S')}")
            print("Version:  #{session.mutant_version}")
            print("Ruby:     #{session.ruby_version}")
            print("Subjects: #{session.subject_results.length}")
            print("Alive:    #{failed.flat_map(&:uncovered_results).length}")

            print_alive_results(failed)

            Either::Right.new(nil)
          end
        end # Show

        class Subjects < SessionCommand
          NAME              = 'subjects'
          SHORT_DESCRIPTION = 'List subjects with alive mutation counts'
          SUBCOMMANDS       = [].freeze

          HEADER_FORMAT = '%-6s  %-6s  %s'
          ROW_FORMAT    = '%-6s  %-6s  %s'

        private

          def print_report(session)
            print(HEADER_FORMAT % %w[ALIVE TOTAL SUBJECT])

            session.subject_results
              .sort_by { |sr| -sr.uncovered_results.length }
              .each(&method(:print_subject))

            Either::Right.new(nil)
          end

          def print_subject(subject_result)
            alive = subject_result.uncovered_results.length
            total = subject_result.coverage_results.length

            print(ROW_FORMAT % [alive, total, subject_result.identification])
          end
        end # Subjects

        class GC < self
          NAME              = 'gc'
          SHORT_DESCRIPTION = 'Remove incompatible and old session results'
          SUBCOMMANDS       = [].freeze
          OPTIONS           = %i[add_gc_options].freeze

          DEFAULT_KEEP = 100

          def initialize(*)
            super
            @keep = DEFAULT_KEEP
          end

          def action
            incompatible, compatible = partition_sessions

            incompatible.each(&:delete)

            excess = compatible.length > @keep ? compatible.first(compatible.length - @keep) : []
            excess.each(&:delete)

            print("Removed #{incompatible.length + excess.length} session(s)")

            Either::Right.new(nil)
          end

        private

          def add_gc_options(parser)
            parser.on('--keep=N', Integer, "Keep N most recent sessions (default: #{DEFAULT_KEEP})") do |value|
              @keep = value
            end
          end

          def partition_sessions
            incompatible = []
            compatible   = []

            session_files.each do |path|
              load_session_file(path).either(
                ->(_error) { incompatible << path },
                ->(_session) { compatible << path }
              )
            end

            [incompatible, compatible]
          end

        end # GC

        SUBCOMMANDS = [List, Show, Subjects, GC].freeze
      end # Session
    end # Command
  end # CLI
end # Mutant
