require 'yaml'
require 'equalizer'
require 'memoizable'
require 'ice_nine'

module MutantSpec
  class Warning
    # Return `$stderr` hijack if the top level program is rspec
    #
    # Certain mutations emit warnings which can cause an otherwise passing mutant run
    #   to fail. For example, the `remove_method` mutation will emit a warning when
    #   applied to certain methods like `#initialize`, `#object_id`, and `#__send__`.
    #
    # @param program_name [String] name of top level program
    #
    # @return [Warning::Extractor] if the top level program is rspec
    # @return [$stderr] otherwise
    def self.warning_hijacker_for(program_name)
      if File.basename(program_name).eql?('rspec')
        MutantSpec::Warning::EXTRACTOR
      else
        STDERR
      end
    end

    def self.assert_no_warnings
      return if EXTRACTOR.warnings.empty?

      fail UnexpectedWarnings, EXTRACTOR.warnings.to_a
    end

    class UnexpectedWarnings < StandardError
      MSG = 'Unexpected warnings: %s'.freeze

      def initialize(warnings)
        super(MSG % warnings.join("\n"))
      end
    end

    class Extractor < DelegateClass(IO)
      PATTERN = /\A(?:.+):(?:\d+): warning: (?:.+)\n\z/.freeze

      include Equalizer.new(:whitelist, :seen, :io), Memoizable

      def initialize(io, whitelist)
        @whitelist = whitelist
        @seen      = Set.new
        @io        = io

        super(io)
      end

      def write(message)
        return super if PATTERN !~ message

        add(message.chomp)

        self
      end

      def warnings
        seen.dup
      end
      memoize :warnings

    private

      def add(warning)
        return if whitelist.any?(&warning.public_method(:end_with?))

        seen << warning
      end

      attr_reader :whitelist, :seen, :io
    end

    warnings  = Pathname.new(__dir__).join('warnings.yml').freeze
    whitelist = IceNine.deep_freeze(YAML.load(warnings.read))

    EXTRACTOR = Extractor.new(STDERR, whitelist)
  end
end
