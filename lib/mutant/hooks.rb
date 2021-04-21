# frozen_string_literal: true

module Mutant
  class Hooks
    include Adamantium, Concord::Public.new(:map)

    DEFAULTS = %i[
      env_infection_pre
      env_infection_post
      mutation_insert_post
      mutation_insert_pre
    ].product([EMPTY_ARRAY]).to_h.transform_values(&:freeze).freeze

    MESSAGE = 'Unknown hook %s'

    private_constant(*constants(false))

    class UnknownHook < RuntimeError; end

    def self.assert_name(name)
      fail UnknownHook, MESSAGE % name.inspect unless DEFAULTS.key?(name)
      self
    end

    def self.empty
      new(DEFAULTS)
    end

    def merge(other)
      self.class.new(
        other.map.merge(map) { |_key, new, old| (old + new).freeze }.freeze
      )
    end

    def run(name, payload)
      Hooks.assert_name(name)

      map.fetch(name).each { |block| block.call(payload) }

      self
    end

    class Builder
      def initialize
        @map = DEFAULTS.transform_values(&:dup)
      end

      def register(name, &block)
        Hooks.assert_name(name)

        @map.fetch(name) << block

        self
      end

      def to_hooks
        Hooks.new(@map.transform_values(&:freeze).freeze)
      end
    end # Builder

    # rubocop:disable Security/Eval
    def self.load_pathname(pathname)
      hooks = Builder.new

      binding.eval(pathname.read, pathname.to_s)

      hooks.to_hooks
    end
    # rubocop:enable Security/Eval

    def self.load_config(config)
      config.hooks.reduce(empty) do |current, path|
        current.merge(load_pathname(path))
      end
    end
  end # Hooks
end # Mutant
