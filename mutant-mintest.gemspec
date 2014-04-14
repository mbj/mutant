# encoding: utf-8
#
require File.expand_path('../lib/mutant/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'mutant-minitest'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Minitest integration for mutant'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files -- lib/mutant{-,/}minitest.rb lib/mutant/minitest`.split("\n")
  gem.test_files       = `git ls-files -- spec/{unit/mutant/minitest,integration/minitest}`.split("\n")
  gem.extra_rdoc_files = %w[TODO LICENSE]

  gem.add_runtime_dependency('mutant', "~> #{gem.version}")

  gem.add_development_dependency('bundler', '~> 1.3', '>= 1.3.5')
end
