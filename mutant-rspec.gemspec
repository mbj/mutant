# frozen_string_literal: true

require_relative 'lib/mutant/version'

Gem::Specification.new do |gem|
  gem.name        = 'mutant-rspec'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Rspec integration for mutant'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'Nonstandard'

  gem.require_paths    = %w[lib]
  gem.files            = %w[lib/mutant/integration/rspec.rb]
  gem.extra_rdoc_files = %w[LICENSE]

  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.required_ruby_version = '>= 3.2'

  gem.add_dependency('mutant', "= #{gem.version}")
  gem.add_dependency('rspec-core', '>= 3.8.0', '< 4.0.0')
end
