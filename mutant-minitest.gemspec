# frozen_string_literal: true

require File.expand_path('lib/mutant/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'mutant-minitest'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = %w[mbj@schirp-dso.com]
  gem.description = 'Minitest integration for mutant'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files -- lib/mutant/{minitest,/integration/minitest.rb}`.split("\n")
  gem.test_files       = `git ls-files -- spec/integration/mutant/minitest.rb`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE]

  gem.add_runtime_dependency('minitest', '~> 5.11')
  gem.add_runtime_dependency('mutant',   "~> #{gem.version}")
end
