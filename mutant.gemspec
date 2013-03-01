# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name        = 'mutant'
  gem.version     = '0.2.20'
  gem.authors     = [ 'Markus Schirp' ]
  gem.email       = [ 'mbj@seonic.net' ]
  gem.description = 'Mutation testing for ruby'
  gem.summary     = 'Mutation testing tool for ruby under MRI and Rubinius'
  gem.homepage    = 'https://github.com/mbj/mutant'

  gem.require_paths    = [ 'lib' ]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- spec`.split("\n")
  gem.extra_rdoc_files = %w[TODO LICENSE]
  gem.executables       = [ 'mutant' ]

  gem.add_runtime_dependency('backports',           '~> 2.8.2')
  gem.add_runtime_dependency('to_source',           '~> 0.2.14')
  gem.add_runtime_dependency('ice_nine',            '~> 0.7.0')
  gem.add_runtime_dependency('descendants_tracker', '~> 0.0.1')
  gem.add_runtime_dependency('adamantium',          '~> 0.0.6')
  gem.add_runtime_dependency('equalizer',           '~> 0.0.4')
  gem.add_runtime_dependency('inflecto',            '~> 0.0.2')
  gem.add_runtime_dependency('abstract_type',       '~> 0.0.3')
  gem.add_runtime_dependency('diff-lcs',            '~> 1.1.3')
end
