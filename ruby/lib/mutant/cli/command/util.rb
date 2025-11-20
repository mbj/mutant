# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Util < self
        NAME              = 'util'
        SHORT_DESCRIPTION = 'Utility subcommands'

        class Mutation < self
          NAME              = 'mutation'
          SHORT_DESCRIPTION = 'Print mutations of a code snippet'
          SUBCOMMANDS       = [].freeze
          OPTIONS           = %i[add_target_options].freeze

          def action
            @ignore_patterns.map! do |syntax|
              AST::Pattern.parse(syntax).from_right do |message|
                return Either::Left.new(message)
              end
            end

            if @targets.map(&method(:print_mutations)).all?
              Either::Right.new(nil)
            else
              Either::Left.new('Invalid mutation detected!')
            end
          end

        private

          class Target
            include Adamantium

            def node
              Unparser.parse(source)
            end
            memoize :node

            class File < self
              include Anima.new(:pathname, :source)

              public :source

              def identification
                "file:#{pathname}"
              end
            end # File

            class Source < self
              include Anima.new(:source)

              def identification
                '<cli-source>'
              end
            end # source
          end # Target

          def initialize(_arguments)
            super

            @targets         = []
            @ignore_patterns = []
          end

          def add_target_options(parser)
            parser.on('-e', '--evaluate SOURCE') do |source|
              @targets << Target::Source.new(source:)
            end

            parser.on('-i', '--ignore-pattern AST_PATTERN') do |pattern|
              @ignore_patterns << pattern
            end
          end

          # rubocop:disable Metrics/MethodLength
          def print_mutations(target)
            world.stdout.puts(target.identification)

            success = true

            Mutator::Node.mutate(
              config: Mutant::Mutation::Config::DEFAULT.with(ignore_patterns: @ignore_patterns),
              node:   target.node
            ).each do |mutation|
              Mutant::Mutation::Evil.from_node(subject: target, node: mutation).either(
                ->(violation) { world.stdout.puts(violation.report); success = false },
                lambda { |object|
                  Reporter::CLI::Printer::Mutation.call(
                    object:,
                    output: world.stdout
                  )
                }
              )
            end

            success
          end

          def parse_remaining_arguments(arguments)
            @targets.concat(
              arguments.map do |argument|
                parse_pathname(argument)
                  .bind(&method(:read_file))
                  .from_right { |error| return Either::Left.new(error) }
              end
            )

            Either::Right.new(self)
          end

          def read_file(pathname)
            Either::Right.new(Target::File.new(pathname:, source: pathname.read))
          rescue StandardError => exception
            Either::Left.new("Cannot read file: #{exception}")
          end

          def parse_pathname(input)
            Either.wrap_error(ArgumentError) { Pathname.new(input) }
              .lmap(&:message)
          end
        end # Mutation

        SUBCOMMANDS = [Mutation].freeze
      end # Util
    end # Command
  end # CLI
end # Mutant
