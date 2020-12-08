# frozen_string_literal: true

module Mutant
  module License
    NAME    = 'mutant-license'
    VERSION = ['>= 0.1', '< 0.3'].freeze

    # Load license
    #
    # @param [World] world
    #
    # @return [Either<String,Subscription>]
    #
    # @api private
    def self.apply(world)
      load_mutant_license(world)
        .fmap { license_path(world) }
        .bind { |path| Subscription.load(world, world.json.load(path)) }
    end

    def self.load_mutant_license(world)
      Either
        .wrap_error(LoadError) { world.gem_method.call(NAME, *VERSION) }
        .lmap(&:message)
        .lmap(&method(:check_for_rubygems_mutant_license))
    end
    private_class_method :load_mutant_license

    def self.check_for_rubygems_mutant_license(message)
      if message.include?('already activated mutant-license-0.0.0')
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
