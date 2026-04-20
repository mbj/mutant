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
          world.parse_json(path.read)
            .bind(&Result::Session::CODEC.load_transform.public_method(:call))
        end

        # Shared base for commands that operate on a session
        class SessionCommand < self
          OPTIONS = %i[add_session_id_option].freeze

          UUID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

          private_constant(:UUID_FORMAT)

          def display_config
            @display_config || Reporter::CLI::Printer::DisplayConfig::DEFAULT
          end

          def action
            path = resolve_session_path or return Either::Left.new('No sessions found')

            return Either::Left.new("Session file not found: #{path}") unless path.file?

            load_session_file(path).either(
              lambda { |error|
 Either::Left.new("Failed to load session: #{error}\nRun `mutant session gc` to remove incompatible sessions.")
              },
              method(:run_report)
            )
          end

        private

          def add_session_id_option(parser)
            parser.on('--session-id=ID', 'Session ID to operate on (default: latest)') do |value|
              fail(OptionParser::InvalidArgument, "invalid UUID format: #{value}") unless UUID_FORMAT.match?(value)

              @session_id = value
            end
          end

          def add_verbose_option(parser)
            parser.separator("\nDisplay Options:\n\n")
            parser.on('--verbose', 'Show verbose output') do
              @display_config = Reporter::CLI::Printer::DisplayConfig::VERBOSE
            end
          end

          def resolve_session_path
            if @session_id
              world.pathname.new("#{RESULTS_DIR}/#{@session_id}.json")
            else
              session_files.last
            end
          end

          def run_report(session)
            print("Session:  #{session.session_id}")

            print_report(session)
          end

          abstract_method :print_report
        end # SessionCommand

        class List < self
          NAME              = 'list'
          SHORT_DESCRIPTION = 'List past mutation testing sessions'
          SUBCOMMANDS       = [].freeze

          HEADER_FORMAT    = '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s'
          ROW_FORMAT       = '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s'
          INCOMPATIBLE = '--------------- [incompatible] ---------------'

          def action
            print_header
            session_files.reverse_each(&method(:print_session))

            Either::Right.new(nil)
          end

        private

          def print_header
            print(HEADER_FORMAT % ['ALIVE', 'MUTATIONS', 'SUBJECTS', 'RUNTIME', 'KILLTIME', 'SESSION ID', 'TIMESTAMP'])
          end

          def print_session(path)
            load_session_file(path).either(
              ->(_error) { print(colorize_unsupported(path)) },
              method(:print_session_row)
            )
          end

          def print_session_row(session)
            subjects = session.subject_results

            print(ROW_FORMAT % [
              subjects.sum(&:amount_mutations_alive),
              subjects.sum(&:amount_mutations),
              subjects.length,
              format_time(session.runtime),
              format_time(session.killtime),
              session.session_id,
              session.timestamp.strftime('%Y-%m-%d %H:%M:%S')
            ])
          end

          def format_time(seconds)
            '%.2fs' % seconds
          end

          def colorize_unsupported(path)
            session_id = path.basename('.json')

            Unparser::Color::RED.format(INCOMPATIBLE.ljust(54)) + session_id.to_s
          end
        end # List

        class Show < SessionCommand
          include Mutant::Reporter::CLI::Printer::AliveResults

          NAME              = 'show'
          SHORT_DESCRIPTION = 'Show results of a past session'
          SUBCOMMANDS       = [].freeze
          OPTIONS           = (superclass::OPTIONS + %i[add_verbose_option]).freeze

        private

          def print_report(session)
            failed = session.subject_results.reject(&:success?)

            print("Time:     #{session.timestamp.strftime('%Y-%m-%d %H:%M:%S')}")
            print("Version:  #{session.mutant_version}")
            print("Ruby:     #{session.ruby_version}")
            print("Subjects: #{session.subject_results.length}")
            print("Alive:    #{failed.flat_map(&:uncovered_results).length}")

            print_alive_results(failed)

            Either::Right.new(nil)
          end
        end # Show

        class Subject < SessionCommand
          include Mutant::Reporter::CLI::Printer::AliveResults

          NAME              = 'subject'
          SHORT_DESCRIPTION = 'List subjects or show alive mutations for a specific subject'
          SUBCOMMANDS       = [].freeze
          OPTIONS           = (superclass::OPTIONS + %i[add_verbose_option]).freeze

          HEADER_FORMAT = '%-6s  %-6s  %s'
          ROW_FORMAT    = '%-6s  %-6s  %s'

          def parse_remaining_arguments(arguments)
            case arguments.length
            when 0 then Either::Right.new(self)
            when 1
              @expression = Mutant::Util.one(arguments)
              Either::Right.new(self)
            else
              Either::Left.new('Expected zero or one subject expression argument')
            end
          end

        private

          def print_report(session)
            if @expression
              print_subject_detail(session)
            else
              print_subject_list(session)
            end
          end

          def print_subject_list(session)
            print(HEADER_FORMAT % %w[ALIVE TOTAL SUBJECT])

            session.subject_results
              .sort_by { |subject_result| -subject_result.uncovered_results.length }
              .each(&method(:print_subject_row))

            Either::Right.new(nil)
          end

          def print_subject_row(subject_result)
            alive = subject_result.uncovered_results.length
            total = subject_result.amount_mutations

            print(ROW_FORMAT % [alive, total, subject_result.expression_syntax])
          end

          def print_subject_detail(session)
            subject_result = session.subject_results.detect do |subject_result|
              subject_result.expression_syntax.eql?(@expression)
            end

            return Either::Left.new("Subject not found: #{@expression}") unless subject_result

            print_alive_results([subject_result])

            Either::Right.new(nil)
          end
        end # Subject

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

        SUBCOMMANDS = [List, Show, Subject, GC].freeze
      end # Session
    end # Command
  end # CLI
end # Mutant
