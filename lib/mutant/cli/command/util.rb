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
            @targets.each(&method(:print_mutations))
            Either::Right.new(nil)
          end

        private

          class Target
            include Adamantium

            def node
              Unparser.parse(source)
            end
            memoize :node

            class File < self
              include Concord.new(:pathname, :source)

              public :source

              def identification
                "file:#{pathname}"
              end
            end # File

            class Source < self
              include Concord::Public.new(:source)

              def identification
                '<cli-source>'
              end
            end # source
          end # Target

          def initialize(_arguments)
            super

            @targets = []
          end

          def add_target_options(parser)
            parser.on('-e', '--evaluate SOURCE') do |source|
              @targets << Target::Source.new(source)
            end
          end

          def print_mutations(target)
            world.stdout.puts(target.identification)
            Mutator::Node.mutate(node: target.node).each do |mutation|
              Reporter::CLI::Printer::Mutation.call(
                world.stdout,
                Mutant::Mutation::Evil.new(target, mutation)
              )
            end
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
            Either::Right.new(Target::File.new(pathname, pathname.read))
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
