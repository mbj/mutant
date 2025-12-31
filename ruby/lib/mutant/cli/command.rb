# frozen_string_literal: true

module Mutant
  module CLI
    # rubocop:disable Metrics/ClassLength
    class Command
      include AbstractType, Anima.new(
        :main,
        :parent_names,
        :print_profile,
        :world,
        :zombie
      )

      OPTIONS     = [].freeze
      SUBCOMMANDS = [].freeze

      # Local opt out of option parser defaults
      class OptionParser < ::OptionParser
        # Kill defaults added by option parser that
        # interfere with ours under mutation testing.
        define_method(:add_officious) {}
      end # OptionParser

      # Parse command
      #
      # @return [Command]
      #
      # rubocop:disable Metrics/ParameterLists
      def self.parse(arguments:, parent_names: nil, print_profile: false, world:, zombie: false)
        new(
          main:          nil,
          parent_names:,
          print_profile:,
          world:,
          zombie:
        ).__send__(:parse, arguments)
      end
      # rubocop:enable Metrics/ParameterLists

      # Command name
      #
      # @return [String]
      def self.command_name
        self::NAME
      end

      # Command short description
      #
      # @return [String]
      def self.short_description
        self::SHORT_DESCRIPTION
      end

      # Execute the command, invoke its side effects
      #
      # @return [Bool]
      def call
        main ? main.call : execute
      end

      # Commands full name
      #
      # @return [String]
      def full_name
        [*parent_names, self.class.command_name].join(' ')
      end

      alias_method :print_profile?, :print_profile
      alias_method :zombie?,        :zombie

      abstract_method :action

    private

      def subcommands
        self.class::SUBCOMMANDS
      end

      def execute
        action.either(
          method(:fail_message),
          ->(_) { true }
        )
      end

      def fail_message(message)
        world.stderr.puts(message)
        false
      end

      def parser
        OptionParser.new do |parser|
          parser.banner = "usage: #{banner}"

          add_summary(parser)
          add_global_options(parser)
          add_subcommands(parser)

          effective_options.each do |method_name|
            2.times { parser.separator(nil) }
            __send__(method_name, parser)
          end
        end
      end

      def effective_options
        self.class::OPTIONS
      end

      def capture_main(&block)
        @main = block
      end

      def banner
        if subcommands.any?
          "#{full_name} <#{subcommands.map(&:command_name).join('|')}> [options]"
        else
          "#{full_name} [options]"
        end
      end

      def parse(arguments)
        Either
          .wrap_error(OptionParser::InvalidArgument, OptionParser::InvalidOption) { parser.order(arguments) }
          .lmap(&method(:with_help))
          .bind(&method(:parse_remaining))
      end

      def add_summary(parser)
        parser.separator(nil)
        parser.separator("Summary: #{self.class.short_description}")
        parser.separator(nil)
      end

      # rubocop:disable Metrics/MethodLength
      def add_global_options(parser)
        parser.separator("mutant version: #{VERSION}")
        parser.separator(nil)
        parser.separator('Global Options:')
        parser.separator(nil)

        parser.on('--help', 'Print help') do
          capture_main { world.stdout.puts(parser.help); true }
        end

        parser.on('--version', 'Print mutants version') do
          capture_main { world.stdout.puts("mutant-#{VERSION}"); true }
        end

        parser.on('--profile', 'Profile mutant execution') do
          @print_profile = true
        end

        parser.on('--zombie', 'Run mutant zombified') do
          @zombie = true
        end
      end

      def add_subcommands(parser)
        return unless subcommands.any?

        parser.separator(nil)
        parser.separator('Available subcommands:')
        parser.separator(nil)
        parser.separator(format_subcommands)
      end

      def parse_remaining(remaining)
        return Either::Right.new(self) if main

        if subcommands.any?
          parse_subcommand(remaining)
        else
          parse_remaining_arguments(remaining)
        end
      end

      def parse_subcommand(arguments)
        command_name, *arguments = arguments

        if command_name.nil?
          Either::Left.new(with_help('Missing required subcommand!'))
        else
          find_command(command_name).bind do |command|
            command.parse(
              arguments:,
              parent_names:  [*parent_names, self.class::NAME],
              print_profile:,
              world:,
              zombie:
            )
          end
        end
      end

      def format_subcommands
        commands = subcommands.to_h do |subcommand|
          [subcommand.command_name, subcommand.short_description]
        end

        width = commands.each_key.map(&:length).max

        commands.each_key.map do |name|
          '%-*s - %s' % [width, name, commands.fetch(name)] # rubocop:disable Style/FormatStringToken
        end
      end

      def find_command(name)
        subcommand = subcommands.detect { |command| command.command_name.eql?(name) }

        if subcommand
          Either::Right.new(subcommand)
        else
          Either::Left.new(with_help("Cannot find subcommand #{name.inspect}"))
        end
      end

      def with_help(message)
        "#{full_name}: #{message}\n\n#{parser}"
      end

      def print(message)
        world.stdout.puts(message)
      end
    end # Command
    # rubocop:enable Metrics/ClassLength
  end # CLI
end # Mutant
