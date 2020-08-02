# frozen_string_literal: true

module Mutant
  module License
    NAME    = 'mutant-license'
    VERSION = '~> 0.1.0'
    SLEEP   = 40

    UNLICENSED =
      IceNine.deep_freeze(
        [
          "Soft fail, continuing in #{SLEEP} seconds",
          'Next major version will enforce the license',
          'See https://github.com/mbj/mutant#licensing'
        ]
      )

    def self.apply(world)
      soft_fail(world, license_result(world))
    end

    def self.license_result(world)
      load_mutant_license(world)
        .fmap { license_path(world) }
        .fmap { |path| Subscription.from_json(world.json.load(path)) }
        .bind { |sub| sub.apply(world) }
    end
    private_class_method :license_result

    # ignore :reek:NestedIterators
    def self.soft_fail(world, result)
      result.lmap do |message|
        stderr = world.stderr
        stderr.puts(message)
        UNLICENSED.each { |line| stderr.puts(unlicensed(line)) }
        world.kernel.sleep(SLEEP)
      end

      Either::Right.new(true)
    end
    private_class_method :soft_fail

    def self.load_mutant_license(world)
      Either
        .wrap_error(LoadError) { world.gem_method.call(NAME, VERSION) }
        .lmap(&:message)
        .lmap(&method(:check_for_rubygems_mutant_license))
        .lmap(&method(:unlicensed))
    end

    def self.unlicensed(message)
      "[Mutant-License-Error]: #{message}"
    end

    def self.check_for_rubygems_mutant_license(message)
      if /already activated mutant-license-0.0.0/.match?(message)
        'mutant-license gem from rubygems.org is a dummy'
      else
        message
      end
    end
    private_class_method :check_for_rubygems_mutant_license

    def self.license_path(world)
      world
        .pathname
        .new(world.gem.loaded_specs.fetch(NAME).full_gem_path)
        .join('license.json')
    end
    private_class_method :license_path
  end
end
