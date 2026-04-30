# frozen_string_literal: true

require_relative 'lib/mutant/version'

Gem::Specification.new do |gem|
  gem.name        = 'mutant-tldr'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = %w[mbj@schirp-dso.com]
  gem.description = 'tldr integration for mutant'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'Nonstandard'

  gem.require_paths = %w[lib]
  gem.files         = %w[lib/mutant/tldr/coverage.rb lib/mutant/integration/tldr.rb]

  gem.extra_rdoc_files = %w[LICENSE]

  gem.required_ruby_version = '>= 3.3'

  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.add_dependency('mutant', "= #{gem.version}")
  gem.add_dependency('tldr',   '~> 1.0')
end
