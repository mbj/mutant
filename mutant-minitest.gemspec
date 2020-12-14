# frozen_string_literal: true

require_relative './lib/mutant/version'

Gem::Specification.new do |gem|
  gem.name        = 'mutant-minitest'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = %w[mbj@schirp-dso.com]
  gem.description = 'Minitest integration for mutant'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'Nonstandard'

  gem.require_paths = %w[lib]
  gem.files         = %w[lib/mutant/minitest/coverage.rb lib/mutant/integration/minitest.rb]

  gem.extra_rdoc_files = %w[LICENSE]

  gem.required_ruby_version = '>= 2.5'

  gem.add_runtime_dependency('minitest', '~> 5.11')
  gem.add_runtime_dependency('mutant',   "= #{gem.version}")
end
