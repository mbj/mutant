# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_record/railtie'

Bundler.require(*Rails.groups)

module RailsExample
  # Minimal Rails application used to verify the mutant Rails hook recipes
  # documented in docs/rails.md against every non-EOL Rails version.
  class Application < Rails::Application
    # Track whatever Rails version is actually loaded for this gemfile, so the
    # same app boots unchanged on 7.2, 8.0 and 8.1.
    config.load_defaults("#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}".to_f)

    config.eager_load = true
    config.secret_key_base = 'rails_example_secret_key_base'

    # Configurable on Rails < 8.1; removed (always-on) from 8.1 onward. The same
    # source boots every non-EOL Rails version, so guard rather than drop it.
    if Rails.gem_version < Gem::Version.new('8.1')
      config.active_support.to_time_preserves_timezone = :zone
    end
  end
end
