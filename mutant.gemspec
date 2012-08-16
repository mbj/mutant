# -*- encoding: utf-8 -*-

require File.expand_path('../lib/mutant/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'mutant'
  gem.version     = Mutant::VERSION.dup
  gem.authors     = [ 'Markus Schirp' ]
  gem.email       = [ 'mbj@seonic.net' ]
  gem.description = 'Mutation testing for ruby under rubinius'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/mbj/mutant'

  gem.require_paths    = [ 'lib' ]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- spec`.split("\n")
  gem.extra_rdoc_files = %w[TODO]

  gem.add_runtime_dependency('to_source', '~> 0.1.3')
  gem.add_runtime_dependency('ice_nine',  '~> 0.4.0')
  gem.add_runtime_dependency('backports', '~> 2.6')
  gem.add_runtime_dependency('immutable', '~> 0.0.1')
  gem.add_runtime_dependency('abstract',  '~> 0.0.1')
  gem.add_runtime_dependency('diff-lcs',  '~> 1.1.3')
end
