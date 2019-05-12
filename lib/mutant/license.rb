# frozen_string_literal: true

module Mutant
  module License
    def self.apply(world)
      soft_fail(world, license_result(world))
    end

    def self.license_result(world)
      Subscription.from_json(world.json.load(license_path(world))).apply(world)
    end
    private_class_method :license_result

    def self.soft_fail(world, license_result)
      license_result.lmap do |message|
        stderr = world.stderr
        stderr.puts(message)
        stderr.puts('Soft fail, continuing in 10 seconds')
        world.kernel.sleep(10)
      end

      Either::Right.new(true)
    end
    private_class_method :soft_fail

    def self.license_path(world)
      world
        .pathname
        .new(world.gem.loaded_specs.fetch('mutant-license').full_gem_path)
        .join('license.json')
    end
    private_class_method :license_path
  end
end
