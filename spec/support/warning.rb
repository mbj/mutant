require 'yaml'
require 'equalizer'
require 'memoizable'
require 'ice_nine'

module MutantSpec
  class Warning
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
    whitelist = IceNine.deep_freeze(YAML.load(warnings.read)) # rubocop:disable Security/YAMLLoad

    EXTRACTOR = Extractor.new(STDERR, whitelist)
  end
end
